import 'dart:async';

import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/features/audio/models/quran_reciter.dart';
import 'package:flutter/material.dart';

class QuranFullPlayerScreen extends StatefulWidget {
  const QuranFullPlayerScreen({
    super.key,
    required this.surahName,
    required this.maxAyahNumber,
    required this.currentAyahNumber,
    required this.currentReciter,
    required this.isPlaying,
    required this.isLoading,
    required this.onTogglePlayPause,
    required this.onPreviousAyah,
    required this.onNextAyah,
    required this.onReciterChanged,
  });

  final String Function() surahName;
  final int maxAyahNumber;
  final int Function() currentAyahNumber;
  final QuranReciter Function() currentReciter;
  final bool Function() isPlaying;
  final bool Function() isLoading;
  final Future<void> Function() onTogglePlayPause;
  final Future<void> Function() onPreviousAyah;
  final Future<void> Function() onNextAyah;
  final Future<void> Function(QuranReciter) onReciterChanged;

  @override
  State<QuranFullPlayerScreen> createState() => _QuranFullPlayerScreenState();
}

class _QuranFullPlayerScreenState extends State<QuranFullPlayerScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAyah = widget.currentAyahNumber();
    final reciter = widget.currentReciter();
    final isPlaying = widget.isPlaying();
    final isLoading = widget.isLoading();
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('quranPlayer'))),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              isDark
                  ? scheme.primary.withValues(alpha: 0.3)
                  : scheme.primary.withValues(alpha: 0.14),
              isDark ? scheme.surface : scheme.surface.withValues(alpha: 0.95),
              isDark ? scheme.surface.withValues(alpha: 0.96) : scheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Icon(Icons.graphic_eq_rounded, color: scheme.secondary, size: 90),
              const SizedBox(height: 18),
              Text(
                widget.surahName(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.tr('ayah')} $currentAyah / ${widget.maxAyahNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: isDark ? 0.25 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.secondary.withValues(alpha: 0.5),
                  ),
                ),
                child: DropdownButton<QuranReciter>(
                  value: reciter,
                  dropdownColor: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  underline: const SizedBox.shrink(),
                  style: TextStyle(color: scheme.onSurface),
                  items: kQuranReciters
                      .map(
                        (item) => DropdownMenuItem<QuranReciter>(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (nextReciter) async {
                          if (nextReciter == null) return;
                          await widget.onReciterChanged(nextReciter);
                          if (!mounted) return;
                          setState(() {});
                        },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton.filledTonal(
                    onPressed: currentAyah <= 1 || isLoading
                        ? null
                        : () async {
                            await widget.onPreviousAyah();
                            if (!mounted) return;
                            setState(() {});
                          },
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await widget.onTogglePlayPause();
                            if (!mounted) return;
                            setState(() {});
                          },
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: scheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(26),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 34,
                          ),
                  ),
                  const SizedBox(width: 16),
                  IconButton.filledTonal(
                    onPressed: currentAyah >= widget.maxAyahNumber || isLoading
                        ? null
                        : () async {
                            await widget.onNextAyah();
                            if (!mounted) return;
                            setState(() {});
                          },
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
