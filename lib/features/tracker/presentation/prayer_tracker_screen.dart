import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PrayerTrackerScreen extends StatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  State<PrayerTrackerScreen> createState() => _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends State<PrayerTrackerScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: today,
    );

    if (picked == null) return;
    final normalized = DateTime(picked.year, picked.month, picked.day);
    if (normalized == _selectedDate) return;

    setState(() => _selectedDate = normalized);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final l10n = context.l10n;
    final selectedTracker = controller.prayerTrackerForDate(_selectedDate);
    final selectedCompleted = selectedTracker.values
        .where((value) => value)
        .length;
    final selectedPercent = selectedCompleted / AppConstants.prayerOrder.length;
    final weeklyPercent = controller.weeklyPrayerCompletionPercent();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = _selectedDate == today;
    final selectedDateLabel = DateFormat('EEE, dd MMM yyyy').format(
      _selectedDate,
    );
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('prayerTracker')),
        actions: <Widget>[
          IconButton(
            tooltip: 'Select date',
            onPressed: () => _pickDate(context),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomPadding),
        children: <Widget>[
          _ProgressCard(
            title: isToday ? l10n.tr('today') : selectedDateLabel,
            percent: selectedPercent,
            caption: l10n.tr('percentCompleted', <String, String>{
              'percent': '${(selectedPercent * 100).round()}',
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
            isToday ? l10n.tr('markTodaysPrayers') : 'Mark prayers for $selectedDateLabel',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...AppConstants.prayerOrder.map((prayer) {
            final checked = selectedTracker[prayer] ?? false;
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
                      date: _selectedDate,
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
