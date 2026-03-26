import 'package:azan_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppGradientButton extends StatefulWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  @override
  State<AppGradientButton> createState() => _AppGradientButtonState();
}

class _AppGradientButtonState extends State<AppGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed ? 0.985 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: widget.onPressed,
          onHighlightChanged: enabled
              ? (active) => setState(() => _pressed = active)
              : null,
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled
                  ? AppGradients.primary
                  : LinearGradient(
                      colors: <Color>[
                        Colors.grey.withValues(alpha: 0.45),
                        Colors.grey.withValues(alpha: 0.4),
                      ],
                    ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppThemeColors.deepGreen.withValues(alpha: 0.26),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: widget.padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
