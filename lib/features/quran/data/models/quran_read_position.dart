class QuranReadPosition {
  const QuranReadPosition({
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
    };
  }

  factory QuranReadPosition.fromMap(Map<String, dynamic> map) {
    return QuranReadPosition(
      surahNumber: map['surahNumber'] as int,
      ayahNumber: map['ayahNumber'] as int,
    );
  }
}
