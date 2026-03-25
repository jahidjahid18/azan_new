import 'package:flutter/material.dart';

enum ThemeStyleOption { muslimPro, glassBlue, emerald, sunset, monochrome }

extension ThemeStyleOptionX on ThemeStyleOption {
  String get key => switch (this) {
    ThemeStyleOption.muslimPro => 'muslim_pro',
    ThemeStyleOption.glassBlue => 'glass_blue',
    ThemeStyleOption.emerald => 'emerald',
    ThemeStyleOption.sunset => 'sunset',
    ThemeStyleOption.monochrome => 'monochrome',
  };

  String get label => switch (this) {
    ThemeStyleOption.muslimPro => 'Muslim Pro Inspired',
    ThemeStyleOption.glassBlue => 'Glassy Blue',
    ThemeStyleOption.emerald => 'Emerald',
    ThemeStyleOption.sunset => 'Sunset',
    ThemeStyleOption.monochrome => 'Monochrome',
  };

  Color get seedColor => switch (this) {
    ThemeStyleOption.muslimPro => const Color(0xFF12223A),
    ThemeStyleOption.glassBlue => const Color(0xFF1A78C6),
    ThemeStyleOption.emerald => const Color(0xFF136A4F),
    ThemeStyleOption.sunset => const Color(0xFFBD5B1E),
    ThemeStyleOption.monochrome => const Color(0xFF3B4752),
  };

  static ThemeStyleOption fromKey(String? value) {
    return ThemeStyleOption.values.firstWhere(
      (option) => option.key == value,
      orElse: () => ThemeStyleOption.muslimPro,
    );
  }
}
