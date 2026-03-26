import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
    this.useAlternative = false,
  });

  final Widget child;
  final bool useAlternative;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final style = context.select<AppController, ThemeStyleOption>(
      (c) => c.themeStyle,
    );
    final gradient = AppGradients.backgroundFor(
      style: style,
      brightness: brightness,
      alternative: useAlternative,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
