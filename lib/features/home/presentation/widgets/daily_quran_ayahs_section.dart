import 'dart:async';

import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/audio/models/quran_reciter.dart';
import 'package:azan_app/features/audio/services/quran_audio_service.dart';
import 'package:azan_app/features/quran/data/models/quran_ayah.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:azan_app/features/quran/data/quran_repository.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

class DailyQuranAyahsSection extends StatefulWidget {
  const DailyQuranAyahsSection({super.key, required this.translationLanguage});

  final AppLanguage translationLanguage;

  @override
  State<DailyQuranAyahsSection> createState() => _DailyQuranAyahsSectionState();
}

class _DailyQuranAyahsSectionState extends State<DailyQuranAyahsSection> {
  static const int _dailyAyahCount = 3;
  static const double _minZoom = 0.85;
  static const double _maxZoom = 1.4;
  static const double _zoomStep = 0.1;
  final QuranRepository _repository = QuranRepository();
  final QuranAudioService _audioService = QuranAudioService();
  final QuranReciter _reciter = kQuranReciters.first;
  late Future<List<QuranSurah>> _surahsFuture;
  AppLanguage? _loadedLanguage;
  late String _activeDayKey;
  int? _surahStartIndexOverride;
  int? _ayahSeedOverride;
  int? _legacyFlatStartIndex;
  String? _playingAyahKey;
  String? _loadingAyahKey;
  StreamSubscription<PlayerState>? _playerStateSub;
  double _contentZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _activeDayKey = _dateKey(DateTime.now());
    _loadStateForDay(_activeDayKey);
    _loadedLanguage = widget.translationLanguage;
    _surahsFuture = _repository.loadSurahs(
      translationLanguage: widget.translationLanguage,
    );
    _playerStateSub = _audioService.player.playerStateStream.listen((_) {
      if (!mounted) return;
      setState(() {});
    });
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
  void dispose() {
    _playerStateSub?.cancel();
    _audioService.dispose();
    super.dispose();
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

        final surahs = snapshot.data!;
        final picks = _pickDailyAyahs(surahs: surahs, count: _dailyAyahCount);
        if (picks.isEmpty) {
          return const SizedBox.shrink();
        }

        final scheme = Theme.of(context).colorScheme;
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_contentZoom)),
          child: AppSurfaceCard(
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
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        _headerActionButton(
                          context: context,
                          icon: Icons.text_decrease_rounded,
                          onPressed: _contentZoom <= _minZoom
                              ? null
                              : () => _changeZoom(-_zoomStep),
                        ),
                        const SizedBox(width: 6),
                        _headerActionButton(
                          context: context,
                          icon: Icons.text_increase_rounded,
                          onPressed: _contentZoom >= _maxZoom
                              ? null
                              : () => _changeZoom(_zoomStep),
                        ),
                        const SizedBox(width: 6),
                        _headerActionButton(
                          context: context,
                          icon: Icons.refresh_rounded,
                          tooltip: l10n.tr('refreshDailyAyahs'),
                          onPressed: () => _refreshAyahs(surahs),
                        ),
                      ],
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
                  final ayahKey = _ayahKey(item);
                  final isPlayingThisAyah =
                      _playingAyahKey == ayahKey &&
                      _audioService.player.playing;
                  final isLoadingThisAyah = _loadingAyahKey == ayahKey;

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
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${item.surah.nameArabic} - \u0627\u0644\u0622\u064A\u0629 ${item.ayah.number}',
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'NotoNaskhArabic',
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.surah.nameEnglish} - ${l10n.tr('ayah')} ${item.ayah.number}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: l10n.tr(
                                  isPlayingThisAyah ? 'pause' : 'play',
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: isLoadingThisAyah
                                    ? null
                                    : () => _toggleAyahAudio(item),
                                icon: isLoadingThisAyah
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        isPlayingThisAyah
                                            ? Icons.pause_circle_filled_rounded
                                            : Icons.play_circle_fill_rounded,
                                        size: 26,
                                        color: scheme.primary,
                                      ),
                              ),
                            ],
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
    _loadStateForDay(todayKey);
  }

  Widget _headerActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        iconSize: 20,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }

  void _changeZoom(double delta) {
    final next = (_contentZoom + delta).clamp(_minZoom, _maxZoom);
    if (next == _contentZoom) {
      return;
    }
    setState(() => _contentZoom = next);
  }

  List<_DailyAyahItem> _pickDailyAyahs({
    required List<QuranSurah> surahs,
    required int count,
  }) {
    final eligibleSurahs = surahs
        .where((surah) => surah.ayahs.isNotEmpty)
        .toList(growable: false);
    if (eligibleSurahs.isEmpty || count <= 0) {
      return <_DailyAyahItem>[];
    }

    final targetCount = count <= eligibleSurahs.length
        ? count
        : eligibleSurahs.length;
    final startSurahIndex = _resolvedSurahStartIndex(eligibleSurahs.length);
    final ayahSeed = _resolvedAyahSeed();

    return List<_DailyAyahItem>.generate(targetCount, (index) {
      final surah =
          eligibleSurahs[(startSurahIndex + index) % eligibleSurahs.length];
      final ayahIndex =
          (ayahSeed + (index * 13) + surah.number) % surah.ayahs.length;
      final ayah = surah.ayahs[ayahIndex];
      return _DailyAyahItem(surah: surah, ayah: ayah);
    });
  }

  int _resolvedSurahStartIndex(int totalSurahs) {
    if (totalSurahs <= 0) {
      return 0;
    }
    if (_surahStartIndexOverride != null && _surahStartIndexOverride! >= 0) {
      return _surahStartIndexOverride! % totalSurahs;
    }
    if (_legacyFlatStartIndex != null && _legacyFlatStartIndex! >= 0) {
      return _legacyFlatStartIndex! % totalSurahs;
    }
    return _defaultStartSurahIndex(totalSurahs);
  }

  int _defaultStartSurahIndex(int totalSurahs) {
    if (totalSurahs <= 0) {
      return 0;
    }
    final daySeed = DateTime.now().difference(DateTime(2020, 1, 1)).inDays;
    return daySeed % totalSurahs;
  }

  int _resolvedAyahSeed() {
    if (_ayahSeedOverride != null && _ayahSeedOverride! >= 0) {
      return _ayahSeedOverride!;
    }
    return DateTime.now().difference(DateTime(2020, 1, 1)).inDays * 17;
  }

  void _loadStateForDay(String dayKey) {
    _surahStartIndexOverride = null;
    _ayahSeedOverride = null;
    _legacyFlatStartIndex = null;
    try {
      if (!Hive.isBoxOpen(AppConstants.hiveBoxName)) {
        return;
      }
      final box = Hive.box<dynamic>(AppConstants.hiveBoxName);
      final stored = box.get(AppConstants.dailyQuranAyahStateStorageKey);
      if (stored is! Map) {
        return;
      }
      final map = Map<String, dynamic>.from(stored);
      if (map['dayKey'] != dayKey) {
        return;
      }
      final surahStartIndex = map['surahStartIndex'];
      if (surahStartIndex is int && surahStartIndex >= 0) {
        _surahStartIndexOverride = surahStartIndex;
      }
      final ayahSeed = map['ayahSeed'];
      if (ayahSeed is int && ayahSeed >= 0) {
        _ayahSeedOverride = ayahSeed;
      }
      final legacyStartIndex = map['startIndex'];
      if (legacyStartIndex is int && legacyStartIndex >= 0) {
        _legacyFlatStartIndex = legacyStartIndex;
      }
    } catch (_) {
      return;
    }
  }

  Future<void> _refreshAyahs(List<QuranSurah> surahs) async {
    final eligibleSurahs = surahs
        .where((surah) => surah.ayahs.isNotEmpty)
        .toList(growable: false);
    if (eligibleSurahs.isEmpty) {
      return;
    }
    final totalSurahs = eligibleSurahs.length;
    final currentSurahStart = _resolvedSurahStartIndex(totalSurahs);
    final nextSurahStart = (currentSurahStart + _dailyAyahCount) % totalSurahs;
    final nextAyahSeed = _resolvedAyahSeed() + 17;

    setState(() {
      _surahStartIndexOverride = nextSurahStart;
      _ayahSeedOverride = nextAyahSeed;
      _legacyFlatStartIndex = null;
    });

    await _persistStateForToday(
      surahStartIndex: nextSurahStart,
      ayahSeed: nextAyahSeed,
    );
  }

  Future<void> _toggleAyahAudio(_DailyAyahItem item) async {
    final ayahKey = _ayahKey(item);
    if (_loadingAyahKey != null) {
      return;
    }

    try {
      if (_playingAyahKey == ayahKey &&
          _audioService.player.audioSource != null) {
        await _audioService.togglePlayPause();
        if (!mounted) return;
        setState(() {});
        return;
      }

      setState(() => _loadingAyahKey = ayahKey);
      await _audioService.playAyah(
        surahNumber: item.surah.number,
        ayahNumber: item.ayah.number,
        reciter: _reciter,
      );
      if (!mounted) return;
      setState(() => _playingAyahKey = ayahKey);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tr('unablePlayAudio'))),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingAyahKey = null);
      }
    }
  }

  Future<void> _persistStateForToday({
    required int surahStartIndex,
    required int ayahSeed,
  }) async {
    try {
      if (!Hive.isBoxOpen(AppConstants.hiveBoxName)) {
        return;
      }
      final box = Hive.box<dynamic>(AppConstants.hiveBoxName);
      await box
          .put(AppConstants.dailyQuranAyahStateStorageKey, <String, dynamic>{
            'dayKey': _activeDayKey,
            'surahStartIndex': surahStartIndex,
            'ayahSeed': ayahSeed,
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

  String _ayahKey(_DailyAyahItem item) {
    return '${item.surah.number}:${item.ayah.number}';
  }
}

class _DailyAyahItem {
  const _DailyAyahItem({required this.surah, required this.ayah});

  final QuranSurah surah;
  final QuranAyah ayah;
}
