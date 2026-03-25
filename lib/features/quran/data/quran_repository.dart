import 'dart:convert';

import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/features/quran/data/models/quran_ayah.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:flutter/services.dart';

class QuranRepository {
  static const String _transliterationAssetPath =
      'assets/data/quran_transliteration_en.json';

  List<QuranSurah>? _arabicCache;
  final Map<String, List<QuranSurah>> _localizedCache =
      <String, List<QuranSurah>>{};
  final Map<String, Map<int, Map<int, String>>> _translationCache =
      <String, Map<int, Map<int, String>>>{};
  Map<int, Map<int, String>>? _transliterationCache;

  Future<List<QuranSurah>> loadSurahs({
    required AppLanguage translationLanguage,
  }) async {
    final languageCode = translationLanguage.code;
    if (_localizedCache[languageCode] != null) {
      return _localizedCache[languageCode]!;
    }

    final arabicSurahs = await _loadArabicSurahs();
    final translations = await _loadTranslationsForLanguage(
      translationLanguage: translationLanguage,
    );
    final transliterations = await _loadTransliterations();

    final mergedSurahs = arabicSurahs
        .map((surah) {
          final ayahTranslationMap =
              translations[surah.number] ?? <int, String>{};
          final ayahTransliterationMap =
              transliterations[surah.number] ?? <int, String>{};
          final mergedAyahs = surah.ayahs
              .map(
                (ayah) => QuranAyah(
                  number: ayah.number,
                  text: ayah.text,
                  transliteration: ayahTransliterationMap[ayah.number],
                  translation: ayahTranslationMap[ayah.number],
                ),
              )
              .toList(growable: false);
          return surah.copyWith(ayahs: mergedAyahs);
        })
        .toList(growable: false);

    _localizedCache[languageCode] = mergedSurahs;
    return mergedSurahs;
  }

  Future<List<QuranSurah>> _loadArabicSurahs() async {
    if (_arabicCache != null) {
      return _arabicCache!;
    }

    final rawArabic = await rootBundle.loadString('assets/data/quran_ar.json');
    final mapArabic = jsonDecode(rawArabic) as Map<String, dynamic>;
    _arabicCache = (mapArabic['surahs'] as List<dynamic>)
        .map((item) => QuranSurah.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
    return _arabicCache!;
  }

  Future<Map<int, Map<int, String>>> _loadTranslationsForLanguage({
    required AppLanguage translationLanguage,
  }) async {
    final languageCode = translationLanguage.code;
    if (_translationCache[languageCode] != null) {
      return _translationCache[languageCode]!;
    }

    final raw = await rootBundle.loadString(
      translationLanguage.translationAssetPath,
    );
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    final surahsRaw = parsed['surahs'] as List<dynamic>? ?? <dynamic>[];

    final result = <int, Map<int, String>>{};
    for (var surahIndex = 0; surahIndex < surahsRaw.length; surahIndex++) {
      final ayahsRaw = surahsRaw[surahIndex] as List<dynamic>? ?? <dynamic>[];
      final ayahMap = <int, String>{};
      for (var ayahIndex = 0; ayahIndex < ayahsRaw.length; ayahIndex++) {
        final text = (ayahsRaw[ayahIndex] as String? ?? '').trim();
        if (text.isEmpty) continue;
        ayahMap[ayahIndex + 1] = text;
      }
      result[surahIndex + 1] = ayahMap;
    }

    _translationCache[languageCode] = result;
    return result;
  }

  Future<Map<int, Map<int, String>>> _loadTransliterations() async {
    if (_transliterationCache != null) {
      return _transliterationCache!;
    }

    final raw = await rootBundle.loadString(_transliterationAssetPath);
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    final surahsRaw = parsed['surahs'] as List<dynamic>? ?? <dynamic>[];

    final result = <int, Map<int, String>>{};
    for (var surahIndex = 0; surahIndex < surahsRaw.length; surahIndex++) {
      final ayahsRaw = surahsRaw[surahIndex] as List<dynamic>? ?? <dynamic>[];
      final ayahMap = <int, String>{};
      for (var ayahIndex = 0; ayahIndex < ayahsRaw.length; ayahIndex++) {
        final text = (ayahsRaw[ayahIndex] as String? ?? '').trim();
        if (text.isEmpty) continue;
        ayahMap[ayahIndex + 1] = text;
      }
      result[surahIndex + 1] = ayahMap;
    }

    _transliterationCache = result;
    return result;
  }
}
