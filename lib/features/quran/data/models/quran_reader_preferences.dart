import 'package:azan_app/features/quran/data/models/arabic_font_preset.dart';

class QuranReaderPreferences {
  const QuranReaderPreferences({
    required this.arabicFontSize,
    required this.translationFontSize,
    required this.lineHeight,
    required this.showTranslation,
    required this.fontPreset,
  });

  final double arabicFontSize;
  final double translationFontSize;
  final double lineHeight;
  final bool showTranslation;
  final ArabicFontPreset fontPreset;

  factory QuranReaderPreferences.defaults() {
    return const QuranReaderPreferences(
      arabicFontSize: 30,
      translationFontSize: 15,
      lineHeight: 1.8,
      showTranslation: true,
      fontPreset: ArabicFontPreset.uthmani,
    );
  }

  QuranReaderPreferences copyWith({
    double? arabicFontSize,
    double? translationFontSize,
    double? lineHeight,
    bool? showTranslation,
    ArabicFontPreset? fontPreset,
  }) {
    return QuranReaderPreferences(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      showTranslation: showTranslation ?? this.showTranslation,
      fontPreset: fontPreset ?? this.fontPreset,
    );
  }

  factory QuranReaderPreferences.fromMap(Map<String, dynamic> map) {
    return QuranReaderPreferences(
      arabicFontSize:
          (map['arabic_font_size'] as num?)?.toDouble() ??
          (map['font_size'] as num?)?.toDouble() ??
          30,
      translationFontSize:
          (map['translation_font_size'] as num?)?.toDouble() ?? 15,
      lineHeight: (map['line_height'] as num?)?.toDouble() ?? 1.8,
      showTranslation: map['show_translation'] as bool? ?? true,
      fontPreset: ArabicFontPresetX.fromKey(map['font_preset'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'arabic_font_size': arabicFontSize,
      'translation_font_size': translationFontSize,
      'line_height': lineHeight,
      'show_translation': showTranslation,
      'font_preset': fontPreset.key,
    };
  }
}
