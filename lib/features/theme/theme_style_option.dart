enum ThemeStyleOption { glassBlue, emerald, sunset, monochrome }

extension ThemeStyleOptionX on ThemeStyleOption {
  String get key => switch (this) {
    ThemeStyleOption.glassBlue => 'glass_blue',
    ThemeStyleOption.emerald => 'emerald',
    ThemeStyleOption.sunset => 'sunset',
    ThemeStyleOption.monochrome => 'monochrome',
  };

  String get label => switch (this) {
    ThemeStyleOption.glassBlue => 'Glass Blue',
    ThemeStyleOption.emerald => 'Emerald',
    ThemeStyleOption.sunset => 'Sunset',
    ThemeStyleOption.monochrome => 'Monochrome',
  };

  static ThemeStyleOption fromKey(String? value) {
    return ThemeStyleOption.values.firstWhere(
      (option) => option.key == value,
      orElse: () => ThemeStyleOption.glassBlue,
    );
  }
}
