import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/theme/app_theme.dart';
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
    required this.onOpenFullPlayer,
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
  final VoidCallback onOpenFullPlayer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? const LinearGradient(
                colors: <Color>[Color(0xFF0A2A21), Color(0xFF0F3B2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF8FBF7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, 8, 12, 10 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onOpenFullPlayer,
                tooltip: l10n.tr('openFullPlayer'),
                icon: const Icon(Icons.open_in_full_rounded),
              ),
              Expanded(
                child: Text(
                  '$surahName - ${l10n.tr('ayah')} $ayahNumber/$maxAyahNumber',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              DropdownButton<QuranReciter>(
                value: currentReciter,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(12),
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
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  backgroundColor: AppThemeColors.deepGreen,
                  foregroundColor: Colors.white,
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                label: Text(l10n.tr(isPlaying ? 'pause' : 'play')),
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
