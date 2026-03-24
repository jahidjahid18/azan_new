class QuranAyah {
  const QuranAyah({required this.number, required this.text});

  final int number;
  final String text;

  factory QuranAyah.fromMap(Map<String, dynamic> map) {
    return QuranAyah(number: map['number'] as int, text: map['text'] as String);
  }
}
