import 'package:azan_app/features/daily/data/models/daily_content_item.dart';

class SavedDailyItem {
  const SavedDailyItem({
    required this.id,
    required this.type,
    required this.title,
    required this.text,
    required this.reference,
    required this.savedAt,
  });

  final String id;
  final String type;
  final String title;
  final String text;
  final String reference;
  final DateTime savedAt;

  factory SavedDailyItem.fromDailyContent(DailyContentItem item) {
    final id = '${item.type}:${item.title}:${item.reference}';
    return SavedDailyItem(
      id: id,
      type: item.type,
      title: item.title,
      text: item.text,
      reference: item.reference,
      savedAt: DateTime.now(),
    );
  }

  factory SavedDailyItem.fromMap(Map<String, dynamic> map) {
    return SavedDailyItem(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      text: map['text'] as String,
      reference: map['reference'] as String,
      savedAt:
          DateTime.tryParse(map['saved_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'title': title,
      'text': text,
      'reference': reference,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}
