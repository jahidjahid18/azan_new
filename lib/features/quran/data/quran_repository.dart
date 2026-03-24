import 'dart:convert';

import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:flutter/services.dart';

class QuranRepository {
  List<QuranSurah>? _cache;

  Future<List<QuranSurah>> loadSurahs() async {
    if (_cache != null) {
      return _cache!;
    }

    final raw = await rootBundle.loadString('assets/data/quran_ar.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final surahs = (map['surahs'] as List<dynamic>)
        .map((item) => QuranSurah.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);

    _cache = surahs;
    return _cache!;
  }
}
