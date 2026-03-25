#!/usr/bin/env python3
"""
Fast, reliable JSON locale translator.

Key features:
- Parallel chunk translation with ThreadPoolExecutor
- Large batch requests (default: 80 items/request)
- Placeholder protection/restoration ({name}, {count}, ...)
- Non-blocking retries via resubmission queue
- Ordered output (keys preserved exactly)
- Progress logging
- Reused translator clients per worker thread (connection pooling reuse)

Examples:
  python tool/fast_translate_locales.py --langs ar,ms,id
  python tool/fast_translate_locales.py --langs ta --batch-size 100 --workers 12
  python tool/fast_translate_locales.py --langs fr,de --provider deep-translator
"""

from __future__ import annotations

import argparse
import json
import math
import os
import random
import re
import threading
import time
from collections import defaultdict
from concurrent.futures import FIRST_COMPLETED, Future, ThreadPoolExecutor, wait
from dataclasses import dataclass
from pathlib import Path
from typing import Any

# Optional providers (loaded lazily).
try:
    from googletrans import Translator as GoogleTransTranslator
except Exception:  # pragma: no cover - optional dependency
    GoogleTransTranslator = None

try:
    from deep_translator import GoogleTranslator as DeepGoogleTranslator
except Exception:  # pragma: no cover - optional dependency
    DeepGoogleTranslator = None


PLACEHOLDER_RE = re.compile(r"\{[^}]+\}")
THREAD_LOCAL = threading.local()


@dataclass(frozen=True)
class ChunkTask:
    lang: str
    chunk_index: int
    keys: list[str]
    texts: list[str]


@dataclass
class TaskState:
    task: ChunkTask
    attempts: int = 0
    next_run_at: float = 0.0
    last_error: str = ""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Parallel locale translator with retries and placeholder safety."
    )
    parser.add_argument(
        "--source",
        default="assets/data/app_ui_locales/en.json",
        help="Source locale JSON (default: en.json).",
    )
    parser.add_argument(
        "--output-dir",
        default="assets/data/app_ui_locales",
        help="Output directory for translated JSON files.",
    )
    parser.add_argument(
        "--langs",
        required=True,
        help="Comma-separated language codes, e.g. ar,ms,id",
    )
    parser.add_argument(
        "--provider",
        default="googletrans",
        choices=["googletrans", "deep-translator"],
        help="Translation provider.",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=80,
        help="Items per translation request (recommended 50-100).",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=min(16, (os.cpu_count() or 8) * 2),
        help="Thread count.",
    )
    parser.add_argument(
        "--max-retries",
        type=int,
        default=4,
        help="Retries per failed chunk.",
    )
    parser.add_argument(
        "--base-backoff",
        type=float,
        default=0.35,
        help="Base exponential backoff seconds.",
    )
    parser.add_argument(
        "--lang-map",
        default="",
        help='Optional JSON map for target codes, e.g. {"tt":"ru","ug":"zh-cn"}',
    )
    return parser.parse_args()


def split_chunks(keys: list[str], values: list[str], chunk_size: int) -> list[ChunkTask]:
    chunks: list[ChunkTask] = []
    total = len(keys)
    for i in range(0, total, chunk_size):
        chunk_keys = keys[i : i + chunk_size]
        chunk_vals = values[i : i + chunk_size]
        chunks.append(
            ChunkTask(
                lang="",
                chunk_index=i // chunk_size,
                keys=chunk_keys,
                texts=chunk_vals,
            )
        )
    return chunks


def protect_placeholders(text: str) -> tuple[str, dict[str, str]]:
    placeholders = PLACEHOLDER_RE.findall(text)
    token_map: dict[str, str] = {}
    out = text
    for i, placeholder in enumerate(placeholders):
        token = f"__PH_{i}_X__"
        out = out.replace(placeholder, token)
        token_map[token] = placeholder
    return out, token_map


def restore_placeholders(text: str, token_map: dict[str, str]) -> str:
    out = text
    for token, placeholder in token_map.items():
        variants = {
            token,
            token.lower(),
            token.upper(),
            token.replace("_", " "),
            token.lower().replace("_", " "),
            token.upper().replace("_", " "),
        }
        for variant in variants:
            out = out.replace(variant, placeholder)
    return out


def get_googletrans_client() -> Any:
    client = getattr(THREAD_LOCAL, "googletrans_client", None)
    if client is None:
        if GoogleTransTranslator is None:
            raise RuntimeError("googletrans is not installed.")
        # Reused per thread to reduce connection overhead.
        client = GoogleTransTranslator(service_urls=["translate.googleapis.com"])
        # Compatibility fix for googletrans builds expecting either attribute name.
        if not hasattr(client, "raise_Exception"):
            setattr(client, "raise_Exception", getattr(client, "raise_exception", False))
        THREAD_LOCAL.googletrans_client = client
    return client


def translate_batch(
    provider: str,
    texts: list[str],
    source_lang: str,
    target_lang: str,
) -> list[str]:
    if not texts:
        return []

    if provider == "googletrans":
        client = get_googletrans_client()
        result = client.translate(texts, src=source_lang, dest=target_lang)
        if isinstance(result, list):
            translated = [getattr(item, "text", str(item)) for item in result]
        else:
            translated = [getattr(result, "text", str(result))]
        if len(translated) != len(texts):
            raise RuntimeError(
                f"Batch size mismatch: got {len(translated)}, expected {len(texts)}"
            )
        return translated

    if provider == "deep-translator":
        if DeepGoogleTranslator is None:
            raise RuntimeError("deep-translator is not installed.")
        # Per-call instance is safer for thread execution.
        translator = DeepGoogleTranslator(source=source_lang, target=target_lang)
        translated = translator.translate_batch(texts)
        if not isinstance(translated, list):
            translated = [translated]
        translated = [str(item) if item is not None else "" for item in translated]
        if len(translated) != len(texts):
            raise RuntimeError(
                f"Batch size mismatch: got {len(translated)}, expected {len(texts)}"
            )
        return translated

    raise ValueError(f"Unsupported provider: {provider}")


def translate_batch_resilient(
    provider: str,
    texts: list[str],
    source_lang: str,
    target_lang: str,
) -> list[str]:
    """Translate with recursive split fallback for flaky upstream responses."""
    if not texts:
        return []

    try:
        return translate_batch(provider, texts, source_lang, target_lang)
    except Exception:
        if len(texts) == 1:
            # Final fallback: keep source text if single request still fails.
            return [texts[0]]
        mid = len(texts) // 2
        left = translate_batch_resilient(
            provider,
            texts[:mid],
            source_lang,
            target_lang,
        )
        right = translate_batch_resilient(
            provider,
            texts[mid:],
            source_lang,
            target_lang,
        )
        return left + right


def run_chunk(task: ChunkTask, provider: str, source_lang: str, target_lang: str) -> tuple[str, int, dict[str, str]]:
    protected_texts: list[str] = []
    token_maps: list[dict[str, str]] = []
    for text in task.texts:
        protected, token_map = protect_placeholders(text)
        protected_texts.append(protected)
        token_maps.append(token_map)

    translated = translate_batch_resilient(
        provider,
        protected_texts,
        source_lang,
        target_lang,
    )
    restored = [restore_placeholders(t, m).strip() for t, m in zip(translated, token_maps)]
    payload = {k: (v if v else original) for k, v, original in zip(task.keys, restored, task.texts)}
    return task.lang, task.chunk_index, payload


def log_progress(done: int, total: int, lang_done: dict[str, int], lang_total: dict[str, int]) -> None:
    percent = (done / total) * 100 if total else 100.0
    per_lang = ", ".join(
        f"{lang}:{lang_done.get(lang,0)}/{lang_total.get(lang,0)}"
        for lang in sorted(lang_total.keys())
    )
    print(f"[{done}/{total}] {percent:6.2f}% | {per_lang}")


def main() -> int:
    args = parse_args()
    if args.batch_size < 50:
        raise ValueError("batch-size must be at least 50 to match performance requirement.")

    source_path = Path(args.source)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    langs = [lang.strip() for lang in args.langs.split(",") if lang.strip()]
    if not langs:
        raise ValueError("No languages provided.")

    source_data = json.loads(source_path.read_text(encoding="utf-8"))
    if not isinstance(source_data, dict):
        raise ValueError("Source locale must be a JSON object.")

    lang_map: dict[str, str] = {}
    if args.lang_map:
        lang_map = json.loads(args.lang_map)
        if not isinstance(lang_map, dict):
            raise ValueError("--lang-map must be a JSON object.")

    keys = list(source_data.keys())
    values = [str(source_data[k]) for k in keys]
    base_chunks = split_chunks(keys, values, args.batch_size)

    tasks: list[TaskState] = []
    lang_total_chunks: dict[str, int] = {}
    for lang in langs:
        lang_tasks: list[TaskState] = []
        for chunk in base_chunks:
            lang_tasks.append(
                TaskState(
                    task=ChunkTask(
                        lang=lang,
                        chunk_index=chunk.chunk_index,
                        keys=chunk.keys,
                        texts=chunk.texts,
                    )
                )
            )
        tasks.extend(lang_tasks)
        lang_total_chunks[lang] = len(lang_tasks)

    total_chunks = len(tasks)
    print(
        f"Starting translation: langs={langs}, chunks={total_chunks}, "
        f"batch={args.batch_size}, workers={args.workers}, provider={args.provider}"
    )

    results: dict[str, dict[int, dict[str, str]]] = defaultdict(dict)
    lang_done_chunks: dict[str, int] = defaultdict(int)
    completed = 0

    by_id = {id(task_state.task): task_state for task_state in tasks}
    delayed: list[TaskState] = []
    in_flight: dict[Future[Any], int] = {}

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        # Initial submit.
        now = time.monotonic()
        for state in tasks:
            state.attempts += 1
            target = lang_map.get(state.task.lang, state.task.lang)
            future = executor.submit(
                run_chunk,
                state.task,
                args.provider,
                "en",
                target,
            )
            in_flight[future] = id(state.task)

        while in_flight or delayed:
            if not in_flight:
                # Only delayed retries exist.
                delayed.sort(key=lambda s: s.next_run_at)
                wait_time = max(0.0, delayed[0].next_run_at - time.monotonic())
                if wait_time > 0:
                    time.sleep(min(wait_time, 0.05))
                now = time.monotonic()
                ready = [d for d in delayed if d.next_run_at <= now]
                delayed = [d for d in delayed if d.next_run_at > now]
                for state in ready:
                    target = lang_map.get(state.task.lang, state.task.lang)
                    future = executor.submit(
                        run_chunk,
                        state.task,
                        args.provider,
                        "en",
                        target,
                    )
                    in_flight[future] = id(state.task)
                continue

            done, _ = wait(in_flight.keys(), timeout=0.05, return_when=FIRST_COMPLETED)
            if not done:
                # Submit retries that are ready while workers are busy.
                now = time.monotonic()
                ready = [d for d in delayed if d.next_run_at <= now]
                delayed = [d for d in delayed if d.next_run_at > now]
                for state in ready:
                    target = lang_map.get(state.task.lang, state.task.lang)
                    future = executor.submit(
                        run_chunk,
                        state.task,
                        args.provider,
                        "en",
                        target,
                    )
                    in_flight[future] = id(state.task)
                continue

            for fut in done:
                task_id = in_flight.pop(fut)
                state = by_id[task_id]
                try:
                    lang, chunk_index, payload = fut.result()
                    results[lang][chunk_index] = payload
                    lang_done_chunks[lang] += 1
                    completed += 1
                    log_progress(completed, total_chunks, lang_done_chunks, lang_total_chunks)
                except Exception as exc:  # noqa: PERF203
                    state.last_error = str(exc)
                    if state.attempts < args.max_retries:
                        state.attempts += 1
                        # Non-blocking retry: queue retry without blocking worker threads.
                        backoff = args.base_backoff * (2 ** (state.attempts - 2))
                        jitter = random.uniform(0.0, 0.08)
                        state.next_run_at = time.monotonic() + backoff + jitter
                        delayed.append(state)
                    else:
                        raise RuntimeError(
                            f"Chunk failed after {args.max_retries} attempts: "
                            f"lang={state.task.lang}, chunk={state.task.chunk_index}, "
                            f"last_error={state.last_error}"
                        ) from exc

    # Rebuild ordered JSON files by original key order.
    for lang in langs:
        expected_chunks = math.ceil(len(keys) / args.batch_size)
        translated_map: dict[str, str] = {}
        for chunk_index in range(expected_chunks):
            payload = results[lang].get(chunk_index)
            if payload is None:
                raise RuntimeError(f"Missing translated chunk for {lang}: chunk={chunk_index}")
            translated_map.update(payload)

        ordered = {k: translated_map.get(k, source_data[k]) for k in keys}
        out_path = output_dir / f"{lang}.json"
        out_path.write_text(
            json.dumps(ordered, ensure_ascii=False, separators=(",", ":")),
            encoding="utf-8",
        )
        changed = sum(1 for k in keys if ordered[k] != source_data[k])
        print(f"Wrote {out_path} | translated_keys={changed}/{len(keys)}")

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
