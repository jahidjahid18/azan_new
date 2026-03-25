import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriDateCard extends StatelessWidget {
  const HijriDateCard({super.key, required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hijri = HijriCalendar.fromDate(now);
    final ramadanCountdown = _daysUntilNextRamadan(hijri: hijri, now: now);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.tr('hijriDate'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            hijri.toFormat('dd MMMM yyyy'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            ramadanCountdown == 0
                ? l10n.tr('ramadanStarted')
                : l10n.tr('daysUntilRamadan', <String, String>{
                    'days': '$ramadanCountdown',
                  }),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _daysUntilNextRamadan({
    required HijriCalendar hijri,
    required DateTime now,
  }) {
    final isPastRamadanStart =
        hijri.hMonth > 9 || (hijri.hMonth == 9 && hijri.hDay > 1);

    final targetHijriYear = isPastRamadanStart ? hijri.hYear + 1 : hijri.hYear;
    final ramadanStartGregorian = hijri.hijriToGregorian(targetHijriYear, 9, 1);

    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      ramadanStartGregorian.year,
      ramadanStartGregorian.month,
      ramadanStartGregorian.day,
    );
    final difference = target.difference(today).inDays;
    return difference < 0 ? 0 : difference;
  }
}
