class QuranBookmark {
  const QuranBookmark({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
  });

  final int surahNumber;
  final int ayahNumber;
  final String surahName;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahName': surahName,
    };
  }

  factory QuranBookmark.fromMap(Map<String, dynamic> map) {
    return QuranBookmark(
      surahNumber: map['surahNumber'] as int,
      ayahNumber: map['ayahNumber'] as int,
      surahName: map['surahName'] as String? ?? '',
    );
  }
}
