import 'dart:ui';

import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.margin,
    this.backgroundColor,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final style = context.select<AppController, ThemeStyleOption>(
      (c) => c.themeStyle,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final effectiveGradient =
        gradient ??
        (backgroundColor == null
            ? LinearGradient(
                colors: isDark
                    ? <Color>[
                        (Theme.of(context).cardTheme.color ??
                                const Color(0xFF0D2A21))
                            .withValues(alpha: 0.96),
                        scheme.secondary.withValues(alpha: 0.12),
                      ]
                    : <Color>[
                        (Theme.of(context).cardTheme.color ?? Colors.white)
                            .withValues(alpha: 0.98),
                        scheme.secondary.withValues(alpha: 0.06),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null);

    final baseDecoration = BoxDecoration(
      color: effectiveGradient == null
          ? (backgroundColor ?? Theme.of(context).cardTheme.color)
          : null,
      gradient: effectiveGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.045),
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : const Color(0xFF0F172A).withValues(alpha: 0.09),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );

    if (style == ThemeStyleOption.glass) {
      final decoration = BoxDecoration(
        color: isDark
            ? const Color(0x6622384D)
            : Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      );
      return AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: decoration,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      );
    }

    if (style == ThemeStyleOption.softUi) {
      final neumorphDecoration = BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.38),
                  blurRadius: 18,
                  offset: const Offset(8, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(-6, -6),
                ),
              ]
            : <BoxShadow>[
                const BoxShadow(
                  color: Color(0xFFFFFFFF),
                  blurRadius: 12,
                  offset: Offset(-5, -5),
                ),
                BoxShadow(
                  color: const Color(0xFF74889A).withValues(alpha: 0.24),
                  blurRadius: 14,
                  offset: const Offset(6, 6),
                ),
              ],
      );
      return AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: margin,
        decoration: neumorphDecoration,
        child: Padding(padding: padding, child: child),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: margin,
      decoration: baseDecoration,
      child: Padding(padding: padding, child: child),
    );
  }
}
