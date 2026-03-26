import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/quran/data/models/quran_ayah.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:azan_app/features/quran/data/quran_repository.dart';
import 'package:flutter/material.dart';

class DailyQuranAyahsSection extends StatefulWidget {
  const DailyQuranAyahsSection({super.key, required this.translationLanguage});

  final AppLanguage translationLanguage;

  @override
  State<DailyQuranAyahsSection> createState() => _DailyQuranAyahsSectionState();
}

class _DailyQuranAyahsSectionState extends State<DailyQuranAyahsSection> {
  final QuranRepository _repository = QuranRepository();
  late Future<List<QuranSurah>> _surahsFuture;
  AppLanguage? _loadedLanguage;

  @override
  void initState() {
    super.initState();
    _loadedLanguage = widget.translationLanguage;
    _surahsFuture = _repository.loadSurahs(
      translationLanguage: widget.translationLanguage,
    );
  }

  @override
  void didUpdateWidget(covariant DailyQuranAyahsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_loadedLanguage != widget.translationLanguage) {
      _loadedLanguage = widget.translationLanguage;
      _surahsFuture = _repository.loadSurahs(
        translationLanguage: widget.translationLanguage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<List<QuranSurah>>(
      future: _surahsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppSurfaceCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final picks = _pickDailyAyahs(snapshot.data!, count: 3);
        if (picks.isEmpty) {
          return const SizedBox.shrink();
        }

        return AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.tr('dailyQuranAyahsTitle'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tr('dailyQuranAyahsSubtitle'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ...picks.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == picks.length - 1;
                final transliteration = (item.ayah.transliteration ?? '')
                    .trim();
                final translation = (item.ayah.translation ?? '').trim();

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          '${item.surah.nameEnglish} - ${l10n.tr('ayah')} ${item.ayah.number}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.ayah.text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontFamily: 'NotoNaskhArabic',
                                height: 1.7,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (transliteration.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            transliteration,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                  height: 1.45,
                                ),
                          ),
                        ],
                        if (translation.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            translation,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.45),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  List<_DailyAyahItem> _pickDailyAyahs(
    List<QuranSurah> surahs, {
    required int count,
  }) {
    final allAyahs = <_DailyAyahItem>[];
    for (final surah in surahs) {
      for (final ayah in surah.ayahs) {
        allAyahs.add(_DailyAyahItem(surah: surah, ayah: ayah));
      }
    }
    if (allAyahs.isEmpty) {
      return <_DailyAyahItem>[];
    }

    final daySeed = DateTime.now().difference(DateTime(2020, 1, 1)).inDays;
    final startIndex = daySeed % allAyahs.length;

    return List<_DailyAyahItem>.generate(
      count,
      (index) => allAyahs[(startIndex + index) % allAyahs.length],
    );
  }
}

class _DailyAyahItem {
  const _DailyAyahItem({required this.surah, required this.ayah});

  final QuranSurah surah;
  final QuranAyah ayah;
}
