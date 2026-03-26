import 'dart:ui';

import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AppCardEntranceDirection { auto, left, right, none }

class AppSurfaceCard extends StatefulWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.entranceDirection = AppCardEntranceDirection.auto,
    this.enableEntranceAnimation = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final AppCardEntranceDirection entranceDirection;
  final bool enableEntranceAnimation;

  @override
  State<AppSurfaceCard> createState() => _AppSurfaceCardState();
}

class _AppSurfaceCardState extends State<AppSurfaceCard> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _entered = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = context.select<AppController, ThemeStyleOption>(
      (c) => c.themeStyle,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final effectiveGradient =
        widget.gradient ??
        (widget.backgroundColor == null
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
          ? (widget.backgroundColor ?? Theme.of(context).cardTheme.color)
          : null,
      gradient: effectiveGradient,
      borderRadius: BorderRadius.circular(widget.radius),
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

    final content = Theme(
      data: Theme.of(context).copyWith(textTheme: _cardTextTheme(context)),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (style == ThemeStyleOption.glass) {
      final decoration = BoxDecoration(
        color: isDark
            ? const Color(0x6622384D)
            : Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(widget.radius),
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
      return _buildEntranceWrapper(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(decoration: decoration, child: content),
            ),
          ),
        ),
      );
    }

    if (style == ThemeStyleOption.softUi) {
      final neumorphDecoration = BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(widget.radius),
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
      return _buildEntranceWrapper(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          decoration: neumorphDecoration,
          child: content,
        ),
      );
    }

    return _buildEntranceWrapper(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        decoration: baseDecoration,
        child: content,
      ),
    );
  }

  Widget _buildEntranceWrapper({required Widget child}) {
    if (!widget.enableEntranceAnimation ||
        widget.entranceDirection == AppCardEntranceDirection.none) {
      return child;
    }

    return AnimatedSlide(
      offset: _entered ? Offset.zero : _startOffset(),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _entered ? 1 : 0,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }

  Offset _startOffset() {
    return switch (widget.entranceDirection) {
      AppCardEntranceDirection.left => const Offset(-0.06, 0),
      AppCardEntranceDirection.right => const Offset(0.06, 0),
      AppCardEntranceDirection.auto => _autoStartOffset(),
      AppCardEntranceDirection.none => Offset.zero,
    };
  }

  Offset _autoStartOffset() {
    final signature = widget.key?.hashCode ?? widget.hashCode;
    return signature.isEven ? const Offset(-0.05, 0) : const Offset(0.05, 0);
  }

  TextTheme _cardTextTheme(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headerStyle = (textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.25,
    );
    final bodyStyle = (textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );

    return textTheme.copyWith(
      titleLarge: headerStyle,
      titleMedium: headerStyle,
      titleSmall: headerStyle,
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle,
      bodySmall: bodyStyle.copyWith(fontSize: 13.5),
      labelLarge: bodyStyle.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
