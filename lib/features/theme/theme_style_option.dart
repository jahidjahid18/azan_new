import 'package:flutter/material.dart';

enum ThemeStyleOption { emerald, midnightDark, ocean, sunset, glass, softUi }

const List<ThemeStyleOption> kSelectableThemeStyles = <ThemeStyleOption>[
  ThemeStyleOption.emerald,
  ThemeStyleOption.midnightDark,
  ThemeStyleOption.ocean,
  ThemeStyleOption.sunset,
  ThemeStyleOption.glass,
  ThemeStyleOption.softUi,
];

extension ThemeStyleOptionX on ThemeStyleOption {
  String get key => switch (this) {
    ThemeStyleOption.emerald => 'emerald',
    ThemeStyleOption.midnightDark => 'midnight_dark',
    ThemeStyleOption.ocean => 'ocean',
    ThemeStyleOption.sunset => 'sunset',
    ThemeStyleOption.glass => 'glass',
    ThemeStyleOption.softUi => 'soft_ui',
  };

  String get label => switch (this) {
    ThemeStyleOption.emerald => 'Emerald',
    ThemeStyleOption.midnightDark => 'Midnight Dark',
    ThemeStyleOption.ocean => 'Ocean',
    ThemeStyleOption.sunset => 'Sunset',
    ThemeStyleOption.glass => 'Glass',
    ThemeStyleOption.softUi => 'Soft UI',
  };

  Color get seedColor => switch (this) {
    ThemeStyleOption.emerald => const Color(0xFF0A7A5B),
    ThemeStyleOption.midnightDark => const Color(0xFFD4A62A),
    ThemeStyleOption.ocean => const Color(0xFF1A7FC4),
    ThemeStyleOption.sunset => const Color(0xFF8B4B23),
    ThemeStyleOption.glass => const Color(0xFF6FC7FF),
    ThemeStyleOption.softUi => const Color(0xFF6D8AA6),
  };

  static ThemeStyleOption fromKey(String? value) {
    final normalized = value?.trim().toLowerCase();
    // Legacy compatibility with previous styles.
    if (normalized == 'muslim_pro') return ThemeStyleOption.emerald;
    if (normalized == 'glass_blue') return ThemeStyleOption.glass;
    if (normalized == 'monochrome') return ThemeStyleOption.midnightDark;

    return ThemeStyleOption.values.firstWhere(
      (option) => option.key == normalized,
      orElse: () => ThemeStyleOption.sunset,
    );
  }
}
