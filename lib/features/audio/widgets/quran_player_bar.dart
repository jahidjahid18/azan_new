import 'package:azan_app/features/audio/models/quran_reciter.dart';
import 'package:flutter/material.dart';

class QuranPlayerBar extends StatelessWidget {
  const QuranPlayerBar({
    super.key,
    required this.surahName,
    required this.ayahNumber,
    required this.maxAyahNumber,
    required this.currentReciter,
    required this.isPlaying,
    required this.isLoading,
    required this.onTogglePlayPause,
    required this.onPreviousAyah,
    required this.onNextAyah,
    required this.onReciterChanged,
  });

  final String surahName;
  final int ayahNumber;
  final int maxAyahNumber;
  final QuranReciter currentReciter;
  final bool isPlaying;
  final bool isLoading;
  final Future<void> Function() onTogglePlayPause;
  final Future<void> Function() onPreviousAyah;
  final Future<void> Function() onNextAyah;
  final Future<void> Function(QuranReciter) onReciterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$surahName - Ayah $ayahNumber/$maxAyahNumber',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              DropdownButton<QuranReciter>(
                value: currentReciter,
                underline: const SizedBox.shrink(),
                items: kQuranReciters
                    .map(
                      (reciter) => DropdownMenuItem<QuranReciter>(
                        value: reciter,
                        child: Text(reciter.name),
                      ),
                    )
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (reciter) async {
                        if (reciter == null) return;
                        await onReciterChanged(reciter);
                      },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: ayahNumber <= 1 || isLoading
                    ? null
                    : () async => onPreviousAyah(),
                icon: const Icon(Icons.skip_previous_rounded),
              ),
              FilledButton.icon(
                onPressed: isLoading ? null : () async => onTogglePlayPause(),
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(isPlaying ? 'Pause' : 'Play'),
              ),
              IconButton(
                onPressed: ayahNumber >= maxAyahNumber || isLoading
                    ? null
                    : () async => onNextAyah(),
                icon: const Icon(Icons.skip_next_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
