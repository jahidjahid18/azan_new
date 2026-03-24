import 'package:azan_app/features/quran/data/models/arabic_font_preset.dart';

class QuranReaderPreferences {
  const QuranReaderPreferences({
    required this.fontSize,
    required this.lineHeight,
    required this.nightMode,
    required this.fontPreset,
  });

  final double fontSize;
  final double lineHeight;
  final bool nightMode;
  final ArabicFontPreset fontPreset;

  factory QuranReaderPreferences.defaults() {
    return const QuranReaderPreferences(
      fontSize: 30,
      lineHeight: 1.8,
      nightMode: false,
      fontPreset: ArabicFontPreset.uthmani,
    );
  }

  QuranReaderPreferences copyWith({
    double? fontSize,
    double? lineHeight,
    bool? nightMode,
    ArabicFontPreset? fontPreset,
  }) {
    return QuranReaderPreferences(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      nightMode: nightMode ?? this.nightMode,
      fontPreset: fontPreset ?? this.fontPreset,
    );
  }

  factory QuranReaderPreferences.fromMap(Map<String, dynamic> map) {
    return QuranReaderPreferences(
      fontSize: (map['font_size'] as num?)?.toDouble() ?? 30,
      lineHeight: (map['line_height'] as num?)?.toDouble() ?? 1.8,
      nightMode: map['night_mode'] as bool? ?? false,
      fontPreset: ArabicFontPresetX.fromKey(map['font_preset'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'font_size': fontSize,
      'line_height': lineHeight,
      'night_mode': nightMode,
      'font_preset': fontPreset.key,
    };
  }
}
