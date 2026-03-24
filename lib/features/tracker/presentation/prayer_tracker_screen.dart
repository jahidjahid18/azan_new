import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerTrackerScreen extends StatelessWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final todayTracker = controller.prayerTrackerForDate(DateTime.now());
    final todayPercent = controller.todayPrayerCompletionPercent();
    final weeklyPercent = controller.weeklyPrayerCompletionPercent();
    final streak = controller.currentPrayerStreakDays();
    final heatmap = controller.last30DaysCompletion();

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Today', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: todayPercent),
                const SizedBox(height: 6),
                Text('${(todayPercent * 100).round()}% completed'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Last 7 Days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: weeklyPercent),
                const SizedBox(height: 6),
                Text('${(weeklyPercent * 100).round()}% completed'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            child: Row(
              children: <Widget>[
                const Icon(Icons.local_fire_department_rounded),
                const SizedBox(width: 8),
                Text('Current Streak: $streak full day(s)'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '30-Day Heatmap',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: heatmap
                      .map((value) => _HeatCell(value: value))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mark Today\'s Prayers',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...AppConstants.prayerOrder.map((prayer) {
            final checked = todayTracker[prayer] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(prayer),
                  value: checked,
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

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.primary,
      value,
    );

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
    );
  }
}
