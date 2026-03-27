import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final l10n = context.l10n;
    final todayTracker = controller.prayerTrackerForDate(DateTime.now());
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final completed = todayTracker.values.where((value) => value).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomPadding),
        children: <Widget>[
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Today',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _MetricPill(
                      label: 'Prayers',
                      value: '$completed/${AppConstants.prayerOrder.length}',
                    ),
                    _MetricPill(
                      label: 'Streak',
                      value: '${controller.currentStreak} day(s)',
                    ),
                    _MetricPill(
                      label: 'Quran',
                      value: '${controller.quranReadingTodayMinutes} min',
                    ),
                    _MetricPill(
                      label: 'Tasbih',
                      value: '${controller.dailyTasbihCount}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Today prayers completed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                for (final prayerName in AppConstants.prayerOrder)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: todayTracker[prayerName] ?? false,
                    title: Text(l10n.prayerName(prayerName)),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) async {
                      await context.read<AppController>().setPrayerCompleted(
                        date: DateTime.now(),
                        prayerName: prayerName,
                        completed: value ?? false,
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (controller.dailyContent != null)
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    controller.dailyContent!.type.toLowerCase() == 'hadith'
                        ? 'Daily Hadith'
                        : 'Daily Ayah',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.dailyContent!.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.dailyContent!.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.dailyContent!.reference,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _openDailyContent(context),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open Full'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openDailyContent(BuildContext context) {
    final content = context.read<AppController>().dailyContent;
    if (content == null) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(content.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(content.text),
                const SizedBox(height: 12),
                Text(
                  content.reference,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
