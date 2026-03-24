class QuranReaderPreferences {
  const QuranReaderPreferences({
    required this.fontSize,
    required this.lineHeight,
    required this.nightMode,
  });

  final double fontSize;
  final double lineHeight;
  final bool nightMode;

  factory QuranReaderPreferences.defaults() {
    return const QuranReaderPreferences(
      fontSize: 30,
      lineHeight: 1.8,
      nightMode: false,
    );
  }

  QuranReaderPreferences copyWith({
    double? fontSize,
    double? lineHeight,
    bool? nightMode,
  }) {
    return QuranReaderPreferences(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      nightMode: nightMode ?? this.nightMode,
    );
  }

  factory QuranReaderPreferences.fromMap(Map<String, dynamic> map) {
    return QuranReaderPreferences(
      fontSize: (map['font_size'] as num?)?.toDouble() ?? 30,
      lineHeight: (map['line_height'] as num?)?.toDouble() ?? 1.8,
      nightMode: map['night_mode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'font_size': fontSize,
      'line_height': lineHeight,
      'night_mode': nightMode,
    };
  }
}
