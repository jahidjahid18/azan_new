import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';

class QuranUiTheme {
  static LinearGradient heroGradient(ThemeStyleOption style) {
    return AppGradients.primaryFor(style);
  }

  static LinearGradient panelGradient(ThemeStyleOption style) {
    return AppGradients.alternativeFor(style);
  }

  static LinearGradient softBackground(
    BuildContext context,
    ThemeStyleOption style,
  ) {
    return AppGradients.backgroundFor(
      style: style,
      brightness: Theme.of(context).brightness,
      alternative: false,
    );
  }

  static Color accent(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color accentDark(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
}
