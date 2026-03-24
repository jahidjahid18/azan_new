import 'package:azan_app/features/quran/data/models/quran_ayah.dart';

class QuranSurah {
  const QuranSurah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.ayahCount,
    required this.ayahs,
  });

  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int ayahCount;
  final List<QuranAyah> ayahs;

  factory QuranSurah.fromMap(Map<String, dynamic> map) {
    return QuranSurah(
      number: map['number'] as int,
      nameArabic: map['name_ar'] as String,
      nameEnglish: map['name_en'] as String,
      ayahCount: map['ayah_count'] as int,
      ayahs: (map['ayahs'] as List<dynamic>)
          .map((ayah) => QuranAyah.fromMap(ayah as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
