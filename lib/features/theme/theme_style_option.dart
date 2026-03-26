import 'package:flutter/material.dart';

enum ThemeStyleOption { muslimPro, glassBlue, emerald, sunset, monochrome }

const List<ThemeStyleOption> kSelectableThemeStyles = <ThemeStyleOption>[
  ThemeStyleOption.sunset,
  ThemeStyleOption.emerald,
  ThemeStyleOption.glassBlue,
  ThemeStyleOption.monochrome,
];

extension ThemeStyleOptionX on ThemeStyleOption {
  String get key => switch (this) {
    ThemeStyleOption.muslimPro => 'muslim_pro',
    ThemeStyleOption.glassBlue => 'glass_blue',
    ThemeStyleOption.emerald => 'emerald',
    ThemeStyleOption.sunset => 'sunset',
    ThemeStyleOption.monochrome => 'monochrome',
  };

  String get label => switch (this) {
    ThemeStyleOption.muslimPro => 'Classic',
    ThemeStyleOption.glassBlue => 'Glassy Blue',
    ThemeStyleOption.emerald => 'Emerald',
    ThemeStyleOption.sunset => 'Sunset',
    ThemeStyleOption.monochrome => 'Monochrome',
  };

  Color get seedColor => switch (this) {
    ThemeStyleOption.muslimPro => const Color(0xFF0A5C45),
    ThemeStyleOption.glassBlue => const Color(0xFF1C5687),
    ThemeStyleOption.emerald => const Color(0xFF0A7A5B),
    ThemeStyleOption.sunset => const Color(0xFF8B4B23),
    ThemeStyleOption.monochrome => const Color(0xFF2D3338),
  };

  static ThemeStyleOption fromKey(String? value) {
    return ThemeStyleOption.values.firstWhere(
      (option) => option.key == value,
      orElse: () => ThemeStyleOption.sunset,
    );
  }
}
