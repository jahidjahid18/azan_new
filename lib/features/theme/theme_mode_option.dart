import 'package:flutter/material.dart';

enum ThemeModeOption { system, light, dark }

extension ThemeModeOptionX on ThemeModeOption {
  String get key => switch (this) {
    ThemeModeOption.system => 'system',
    ThemeModeOption.light => 'light',
    ThemeModeOption.dark => 'dark',
  };

  String get label => switch (this) {
    ThemeModeOption.system => 'System',
    ThemeModeOption.light => 'Light',
    ThemeModeOption.dark => 'Dark',
  };

  ThemeMode get flutterThemeMode => switch (this) {
    ThemeModeOption.system => ThemeMode.system,
    ThemeModeOption.light => ThemeMode.light,
    ThemeModeOption.dark => ThemeMode.dark,
  };

  static ThemeModeOption fromKey(String? value) {
    return ThemeModeOption.values.firstWhere(
      (option) => option.key == value,
      orElse: () => ThemeModeOption.system,
    );
  }
}
