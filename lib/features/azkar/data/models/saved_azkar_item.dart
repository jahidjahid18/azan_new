class SavedAzkarItem {
  const SavedAzkarItem({
    required this.id,
    required this.category,
    required this.text,
    required this.source,
    required this.repeat,
    required this.savedAt,
  });

  final String id;
  final String category;
  final String text;
  final String source;
  final int repeat;
  final DateTime savedAt;

  factory SavedAzkarItem.fromMap(Map<String, dynamic> map) {
    return SavedAzkarItem(
      id: map['id'] as String,
      category: map['category'] as String? ?? 'general',
      text: map['text'] as String,
      source: map['source'] as String? ?? '',
      repeat: map['repeat'] as int? ?? 1,
      savedAt:
          DateTime.tryParse(map['saved_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'text': text,
      'source': source,
      'repeat': repeat,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}
