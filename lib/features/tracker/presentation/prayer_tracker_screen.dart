import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/state/app_controller.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
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
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
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
          ),
          const SizedBox(height: 12),
          Text(
            'Mark Today\'s Prayers',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...AppConstants.prayerOrder.map((prayer) {
            final checked = todayTracker[prayer] ?? false;
            return Card(
              child: CheckboxListTile(
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
            );
          }),
        ],
      ),
    );
  }
}
