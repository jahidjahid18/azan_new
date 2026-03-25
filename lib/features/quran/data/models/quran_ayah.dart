class QuranAyah {
  const QuranAyah({required this.number, required this.text, this.translation});

  final int number;
  final String text;
  final String? translation;

  factory QuranAyah.fromMap(Map<String, dynamic> map) {
    return QuranAyah(
      number: map['number'] as int,
      text: map['text'] as String,
      translation:
          map['translation'] as String? ?? map['translation_en'] as String?,
    );
  }

  QuranAyah withTranslation(String? value) {
    return QuranAyah(number: number, text: text, translation: value);
  }
}
