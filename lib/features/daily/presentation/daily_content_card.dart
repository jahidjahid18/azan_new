import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/daily/data/models/daily_content_item.dart';
import 'package:flutter/material.dart';

class DailyContentCard extends StatelessWidget {
  const DailyContentCard({super.key, required this.item});

  final DailyContentItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      gradient: LinearGradient(
        colors: <Color>[
          Theme.of(context).cardTheme.color ?? Colors.white,
          AppThemeColors.softGold.withValues(alpha: 0.12),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.type.toLowerCase() == 'hadith'
                  ? l10n.tr('dailyHadith')
                  : l10n.tr('dailyAyah'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(item.text),
          const SizedBox(height: 10),
          Text(
            item.reference,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
