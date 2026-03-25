class QuranAyah {
  const QuranAyah({
    required this.number,
    required this.text,
    this.transliteration,
    this.translation,
  });

  final int number;
  final String text;
  final String? transliteration;
  final String? translation;

  factory QuranAyah.fromMap(Map<String, dynamic> map) {
    return QuranAyah(
      number: map['number'] as int,
      text: map['text'] as String,
      transliteration:
          map['transliteration'] as String? ??
          map['transliteration_en'] as String?,
      translation:
          map['translation'] as String? ?? map['translation_en'] as String?,
    );
  }

  QuranAyah withLocalizedText({String? transliteration, String? translation}) {
    return QuranAyah(
      number: number,
      text: text,
      transliteration: transliteration,
      translation: translation,
    );
  }
}
