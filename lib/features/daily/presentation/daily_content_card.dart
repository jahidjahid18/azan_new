import 'package:azan_app/core/widgets/glass_card.dart';
import 'package:azan_app/features/daily/data/models/daily_content_item.dart';
import 'package:flutter/material.dart';

class DailyContentCard extends StatelessWidget {
  const DailyContentCard({
    super.key,
    required this.item,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final DailyContentItem item;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.type.toLowerCase() == 'hadith'
                      ? 'Daily Hadith'
                      : 'Daily Ayah',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
