import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/core/widgets/app_gradient_button.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final style = context.select<AppController, ThemeStyleOption>(
      (c) => c.themeStyle,
    );
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomPadding),
      children: <Widget>[
        Text(
          l10n.tr('tasbihCounter'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.tr('tasbihSubtitle'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        AppSurfaceCard(
          gradient: AppGradients.alternativeFor(style),
          child: Column(
            children: <Widget>[
              Text(
                l10n.tr('currentCount'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                'SubhanAllah',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppThemeColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  '${controller.tasbihCount}',
                  key: ValueKey<int>(controller.tasbihCount),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: _TapCircle(
            onTap: () => context.read<AppController>().incrementTasbih(),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: AppGradientButton(
            onPressed: () => context.read<AppController>().resetTasbih(),
            icon: Icons.restart_alt_rounded,
            label: l10n.tr('resetCounter'),
          ),
        ),
      ],
    );
  }
}

class _TapCircle extends StatelessWidget {
  const _TapCircle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: <Color>[const Color(0xFF10213A), scheme.secondary],
            ),
            border: Border.all(
              color: AppThemeColors.gold.withValues(alpha: 0.75),
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: scheme.secondary.withValues(alpha: 0.35),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.touch_app_rounded,
                color: Colors.white,
                size: 34,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tr('tap'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
