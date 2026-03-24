enum ArabicFontPreset { uthmani, naskh, traditional, modern }

extension ArabicFontPresetX on ArabicFontPreset {
  String get key => switch (this) {
    ArabicFontPreset.uthmani => 'uthmani',
    ArabicFontPreset.naskh => 'naskh',
    ArabicFontPreset.traditional => 'traditional',
    ArabicFontPreset.modern => 'modern',
  };

  String get label => switch (this) {
    ArabicFontPreset.uthmani => 'Uthmani',
    ArabicFontPreset.naskh => 'Naskh',
    ArabicFontPreset.traditional => 'Traditional',
    ArabicFontPreset.modern => 'Modern',
  };

  String get family => switch (this) {
    ArabicFontPreset.uthmani => 'Noto Naskh Arabic',
    ArabicFontPreset.naskh => 'Noto Sans Arabic',
    ArabicFontPreset.traditional => 'serif',
    ArabicFontPreset.modern => 'sans-serif',
  };

  static ArabicFontPreset fromKey(String? key) {
    return ArabicFontPreset.values.firstWhere(
      (preset) => preset.key == key,
      orElse: () => ArabicFontPreset.uthmani,
    );
  }
}
