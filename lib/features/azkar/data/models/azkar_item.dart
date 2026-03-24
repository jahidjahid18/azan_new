class AzkarItem {
  const AzkarItem({
    required this.id,
    required this.text,
    required this.repeat,
    required this.source,
  });

  final String id;
  final String text;
  final int repeat;
  final String source;

  factory AzkarItem.fromMap(Map<String, dynamic> map) {
    return AzkarItem(
      id: map['id'] as String,
      text: map['text'] as String,
      repeat: map['repeat'] as int,
      source: map['source'] as String? ?? '',
    );
  }
}
