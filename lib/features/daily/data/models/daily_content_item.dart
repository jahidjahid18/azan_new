class DailyContentItem {
  const DailyContentItem({
    required this.type,
    required this.title,
    required this.text,
    required this.reference,
  });

  final String type;
  final String title;
  final String text;
  final String reference;

  factory DailyContentItem.fromMap(Map<String, dynamic> map) {
    return DailyContentItem(
      type: map['type'] as String? ?? 'ayah',
      title: map['title'] as String? ?? '',
      text: map['text'] as String? ?? '',
      reference: map['reference'] as String? ?? '',
    );
  }
}
