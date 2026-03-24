import 'package:azan_app/features/quran/data/models/quran_read_position.dart';

class QuranBookmark extends QuranReadPosition {
  const QuranBookmark({
    required super.surahNumber,
    required super.ayahNumber,
    required super.surahNameEnglish,
    required super.surahNameArabic,
    required super.updatedAt,
  });

  factory QuranBookmark.fromMap(Map<String, dynamic> map) {
    return QuranBookmark(
      surahNumber: map['surah_number'] as int,
      ayahNumber: map['ayah_number'] as int,
      surahNameEnglish: map['surah_name_en'] as String,
      surahNameArabic: map['surah_name_ar'] as String,
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get key => '$surahNumber:$ayahNumber';
}
