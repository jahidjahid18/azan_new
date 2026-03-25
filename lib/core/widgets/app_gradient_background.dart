import 'package:azan_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

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
    final gradient = switch ((brightness, useAlternative)) {
      (Brightness.light, true) => AppGradients.lightBackgroundAlternative,
      (Brightness.light, false) => AppGradients.lightBackgroundPrimary,
      (Brightness.dark, true) => AppGradients.darkBackgroundAlternative,
      (Brightness.dark, false) => AppGradients.darkBackgroundPrimary,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
