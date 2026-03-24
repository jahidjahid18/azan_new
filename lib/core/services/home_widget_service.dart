import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/utils/duration_formatter.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

class HomeWidgetService {
  static const String providerName = 'PrayerAppWidgetProvider';
  static const String qualifiedProviderName =
      'com.example.azan_app.PrayerAppWidgetProvider';
  static const String compactProviderName = 'PrayerCompactWidgetProvider';
  static const String qualifiedCompactProviderName =
      'com.example.azan_app.PrayerCompactWidgetProvider';
  static const String ramadanProviderName = 'PrayerRamadanWidgetProvider';
  static const String qualifiedRamadanProviderName =
      'com.example.azan_app.PrayerRamadanWidgetProvider';

  static const String cityKey = 'widget_city_name';
  static const String prayerNameKey = 'widget_next_prayer_name';
  static const String prayerTimeKey = 'widget_next_prayer_time';
  static const String countdownKey = 'widget_countdown';
  static const String updatedAtKey = 'widget_updated_at';
  static const String ramadanCountdownKey = 'widget_ramadan_countdown';

  final DateFormat _timeFormat = DateFormat('hh:mm a');
  final DateFormat _dateTimeFormat = DateFormat('dd MMM, hh:mm a');

  Future<void> updateNextPrayerWidget({
    required String cityName,
    required PrayerInfo? nextPrayer,
    required Duration countdown,
  }) async {
    final nextPrayerName = nextPrayer?.name ?? 'No upcoming prayer';
    final nextPrayerTime = nextPrayer == null
        ? '--:--'
        : _timeFormat.format(nextPrayer.time);

    await HomeWidget.saveWidgetData<String>(cityKey, cityName);
    await HomeWidget.saveWidgetData<String>(prayerNameKey, nextPrayerName);
    await HomeWidget.saveWidgetData<String>(prayerTimeKey, nextPrayerTime);
    await HomeWidget.saveWidgetData<String>(
      countdownKey,
      formatDuration(countdown),
    );
    await HomeWidget.saveWidgetData<String>(
      updatedAtKey,
      _dateTimeFormat.format(DateTime.now()),
    );
    await HomeWidget.saveWidgetData<String>(
      ramadanCountdownKey,
      _ramadanCountdownText(),
    );
    await HomeWidget.updateWidget(
      androidName: providerName,
      qualifiedAndroidName: qualifiedProviderName,
    );
    await HomeWidget.updateWidget(
      androidName: compactProviderName,
      qualifiedAndroidName: qualifiedCompactProviderName,
    );
    await HomeWidget.updateWidget(
      androidName: ramadanProviderName,
      qualifiedAndroidName: qualifiedRamadanProviderName,
    );
  }

  String _ramadanCountdownText() {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
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
    final days = target.difference(today).inDays;
    return days <= 0 ? 'Ramadan is now' : '$days day(s) to Ramadan';
  }
}
