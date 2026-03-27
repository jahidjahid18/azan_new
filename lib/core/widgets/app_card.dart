import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.margin,
    this.gradient,
    this.backgroundColor,
    this.enableEntranceAnimation = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool enableEntranceAnimation;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: padding,
      radius: radius,
      margin: margin,
      gradient: gradient,
      backgroundColor: backgroundColor,
      enableEntranceAnimation: enableEntranceAnimation,
      child: child,
    );
  }
}
