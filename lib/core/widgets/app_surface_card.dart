import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final autoGradient =
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: margin,
      decoration: BoxDecoration(
        color: autoGradient == null
            ? (backgroundColor ?? Theme.of(context).cardTheme.color)
            : null,
        gradient: autoGradient,
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
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
