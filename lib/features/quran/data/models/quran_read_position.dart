class QuranReadPosition {
  const QuranReadPosition({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    required this.updatedAt,
  });

  final int surahNumber;
  final int ayahNumber;
  final String surahNameEnglish;
  final String surahNameArabic;
  final DateTime updatedAt;

  factory QuranReadPosition.fromMap(Map<String, dynamic> map) {
    return QuranReadPosition(
      surahNumber: map['surah_number'] as int,
      ayahNumber: map['ayah_number'] as int,
      surahNameEnglish: map['surah_name_en'] as String,
      surahNameArabic: map['surah_name_ar'] as String,
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'surah_name_en': surahNameEnglish,
      'surah_name_ar': surahNameArabic,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
