import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerTrackerScreen extends StatelessWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final l10n = context.l10n;
    final todayTracker = controller.prayerTrackerForDate(DateTime.now());
    final todayPercent = controller.todayPrayerCompletionPercent();
    final weeklyPercent = controller.weeklyPrayerCompletionPercent();
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('prayerTracker'))),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomPadding),
        children: <Widget>[
          _ProgressCard(
            title: l10n.tr('today'),
            percent: todayPercent,
            caption: l10n.tr('percentCompleted', <String, String>{
              'percent': '${(todayPercent * 100).round()}',
            }),
          ),
          const SizedBox(height: 10),
          _ProgressCard(
            title: l10n.tr('last7Days'),
            percent: weeklyPercent,
            caption: l10n.tr('percentCompleted', <String, String>{
              'percent': '${(weeklyPercent * 100).round()}',
            }),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tr('markTodaysPrayers'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...AppConstants.prayerOrder.map((prayer) {
            final checked = todayTracker[prayer] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppSurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.prayerName(prayer),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  value: checked,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onChanged: (value) async {
                    await context.read<AppController>().setPrayerCompleted(
                      date: DateTime.now(),
                      prayerName: prayer,
                      completed: value ?? false,
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.percent,
    required this.caption,
  });

  final String title;
  final double percent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      gradient: LinearGradient(
        colors: <Color>[
          Theme.of(context).cardTheme.color ?? Colors.white,
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.14),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
