import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/quran/data/models/quran_ayah.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:azan_app/features/quran/data/quran_repository.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DailyQuranAyahsSection extends StatefulWidget {
  const DailyQuranAyahsSection({super.key, required this.translationLanguage});

  final AppLanguage translationLanguage;

  @override
  State<DailyQuranAyahsSection> createState() => _DailyQuranAyahsSectionState();
}

class _DailyQuranAyahsSectionState extends State<DailyQuranAyahsSection> {
  static const int _dailyAyahCount = 3;
  final QuranRepository _repository = QuranRepository();
  late Future<List<QuranSurah>> _surahsFuture;
  AppLanguage? _loadedLanguage;
  late String _activeDayKey;
  int? _startIndexOverride;

  @override
  void initState() {
    super.initState();
    _activeDayKey = _dateKey(DateTime.now());
    _startIndexOverride = _loadStartIndexForDay(_activeDayKey);
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
    _syncDayStateIfNeeded();
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

        final allAyahs = _flattenAyahs(snapshot.data!);
        final picks = _pickDailyAyahs(
          allAyahs: allAyahs,
          count: _dailyAyahCount,
        );
        if (picks.isEmpty) {
          return const SizedBox.shrink();
        }

        final scheme = Theme.of(context).colorScheme;
        return AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.tr('dailyQuranAyahsTitle'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.tr('dailyQuranAyahsSubtitle'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: IconButton(
                      tooltip: l10n.tr('refreshDailyAyahs'),
                      visualDensity: VisualDensity.compact,
                      iconSize: 20,
                      onPressed: () => _refreshAyahs(allAyahs),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ),
                ],
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
                      color: scheme.secondary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.38),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
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

  void _syncDayStateIfNeeded() {
    final todayKey = _dateKey(DateTime.now());
    if (todayKey == _activeDayKey) {
      return;
    }
    _activeDayKey = todayKey;
    _startIndexOverride = _loadStartIndexForDay(todayKey);
  }

  List<_DailyAyahItem> _flattenAyahs(List<QuranSurah> surahs) {
    final allAyahs = <_DailyAyahItem>[];
    for (final surah in surahs) {
      for (final ayah in surah.ayahs) {
        allAyahs.add(_DailyAyahItem(surah: surah, ayah: ayah));
      }
    }
    return allAyahs;
  }

  List<_DailyAyahItem> _pickDailyAyahs({
    required List<_DailyAyahItem> allAyahs,
    required int count,
  }) {
    if (allAyahs.isEmpty) {
      return <_DailyAyahItem>[];
    }

    final startIndex = _resolvedStartIndex(allAyahs.length);

    return List<_DailyAyahItem>.generate(
      count,
      (index) => allAyahs[(startIndex + index) % allAyahs.length],
    );
  }

  int _resolvedStartIndex(int totalAyahs) {
    if (totalAyahs <= 0) {
      return 0;
    }
    final persisted = _startIndexOverride;
    if (persisted != null && persisted >= 0) {
      return persisted % totalAyahs;
    }
    return _defaultStartIndex(totalAyahs);
  }

  int _defaultStartIndex(int totalAyahs) {
    if (totalAyahs <= 0) {
      return 0;
    }
    final daySeed = DateTime.now().difference(DateTime(2020, 1, 1)).inDays;
    return daySeed % totalAyahs;
  }

  int? _loadStartIndexForDay(String dayKey) {
    try {
      if (!Hive.isBoxOpen(AppConstants.hiveBoxName)) {
        return null;
      }
      final box = Hive.box<dynamic>(AppConstants.hiveBoxName);
      final stored = box.get(AppConstants.dailyQuranAyahStateStorageKey);
      if (stored is! Map) {
        return null;
      }
      final map = Map<String, dynamic>.from(stored);
      if (map['dayKey'] != dayKey) {
        return null;
      }
      final startIndex = map['startIndex'];
      if (startIndex is int && startIndex >= 0) {
        return startIndex;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> _refreshAyahs(List<_DailyAyahItem> allAyahs) async {
    if (allAyahs.isEmpty) {
      return;
    }
    final totalAyahs = allAyahs.length;
    final current = _resolvedStartIndex(totalAyahs);
    final next = (current + _dailyAyahCount) % totalAyahs;

    setState(() {
      _startIndexOverride = next;
    });

    await _persistStartIndexForToday(next);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.tr('dailyQuranAyahsRefreshed'))),
    );
  }

  Future<void> _persistStartIndexForToday(int startIndex) async {
    try {
      if (!Hive.isBoxOpen(AppConstants.hiveBoxName)) {
        return;
      }
      final box = Hive.box<dynamic>(AppConstants.hiveBoxName);
      await box
          .put(AppConstants.dailyQuranAyahStateStorageKey, <String, dynamic>{
            'dayKey': _activeDayKey,
            'startIndex': startIndex,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (_) {
      // Ignore storage issues to keep UI responsive.
    }
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _DailyAyahItem {
  const _DailyAyahItem({required this.surah, required this.ayah});

  final QuranSurah surah;
  final QuranAyah ayah;
}
