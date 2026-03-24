import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/utils/duration_formatter.dart';
import 'package:azan_app/core/widgets/glass_card.dart';
import 'package:azan_app/features/azkar/presentation/azkar_screen.dart';
import 'package:azan_app/features/calendar/presentation/hijri_date_card.dart';
import 'package:azan_app/features/daily/presentation/daily_content_card.dart';
import 'package:azan_app/features/mosque/presentation/mosque_finder_screen.dart';
import 'package:azan_app/features/tracker/presentation/prayer_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppController>().refreshLocationFromGps(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (controller.location != null)
            _HeaderCard(
              city: controller.location!.cityName,
              now: controller.now,
              nextPrayer: controller.nextPrayer,
              countdown: controller.nextPrayerCountdown,
            )
          else
            _EmptyLocationState(message: controller.startupError),
          const SizedBox(height: 12),
          HijriDateCard(now: controller.now),
          const SizedBox(height: 12),
          _DailyGoalCard(
            completed: controller.completedPrayersToday(),
            total: 5,
            streakDays: controller.currentPrayerStreakDays(),
          ),
          const SizedBox(height: 12),
          if (controller.dailyContent != null)
            DailyContentCard(
              item: controller.dailyContent!,
              isFavorite: controller.isDailyFavorite(controller.dailyContent!),
              onToggleFavorite: () async {
                await context.read<AppController>().toggleDailyFavorite(
                  controller.dailyContent!,
                );
              },
            ),
          const SizedBox(height: 12),
          const _QuickActionsRow(),
          if (controller.location != null) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              'Today\'s Prayer Times',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Includes Sunrise time',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            ...controller.todayPrayers.map(
              (prayer) => _PrayerTile(
                prayer: prayer,
                isNext: _isSamePrayer(prayer, controller.nextPrayer),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isSamePrayer(PrayerInfo prayer, PrayerInfo? nextPrayer) {
    if (nextPrayer == null) return false;
    return prayer.name == nextPrayer.name &&
        prayer.time.year == nextPrayer.time.year &&
        prayer.time.month == nextPrayer.time.month &&
        prayer.time.day == nextPrayer.time.day;
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrayerTrackerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.checklist_rounded),
                label: const Text('Tracker'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MosqueFinderScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Mosques'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AzkarScreen()),
              );
            },
            icon: const Icon(Icons.auto_stories_rounded),
            label: const Text('Daily Azkar'),
          ),
        ),
      ],
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.completed,
    required this.total,
    required this.streakDays,
  });

  final int completed;
  final int total;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final progress = completed / total;

    return GlassCard(
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Daily Goal',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('Streak: $streakDays day(s)'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Complete all 5 prayers today'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 6),
          Text('$completed/$total prayers marked complete'),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.city,
    required this.now,
    required this.nextPrayer,
    required this.countdown,
  });

  final String city;
  final DateTime now;
  final PrayerInfo? nextPrayer;
  final Duration countdown;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm:ss a');
    final prayerTimeFormat = DateFormat('hh:mm a');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF2A78F8), Color(0xFF0D3A9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            city,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeFormat.format(now),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nextPrayer == null
                ? 'Next prayer unavailable'
                : 'Next: ${nextPrayer!.name} (${prayerTimeFormat.format(nextPrayer!.time)})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Starts in ${formatDuration(countdown)}',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({required this.prayer, required this.isNext});

  final PrayerInfo prayer;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final iconColor = isNext
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderRadius: 14,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.access_time_rounded, color: iconColor),
          title: Text(
            prayer.name,
            style: TextStyle(
              fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          subtitle: prayer.isObligatory
              ? null
              : const Text('Additional time (not fard prayer)'),
          trailing: Text(
            DateFormat('hh:mm a').format(prayer.time),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _EmptyLocationState extends StatelessWidget {
  const _EmptyLocationState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: <Widget>[
          const Icon(Icons.location_off_rounded, size: 38),
          const SizedBox(height: 10),
          Text(
            message ??
                'Location not available yet. Open Settings to set location manually or fetch GPS.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
