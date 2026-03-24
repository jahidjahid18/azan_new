import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/utils/duration_formatter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

class HomeWidgetService {
  static const String providerName = 'PrayerAppWidgetProvider';
  static const String qualifiedProviderName =
      'com.example.azan_app.PrayerAppWidgetProvider';

  static const String cityKey = 'widget_city_name';
  static const String prayerNameKey = 'widget_next_prayer_name';
  static const String prayerTimeKey = 'widget_next_prayer_time';
  static const String countdownKey = 'widget_countdown';
  static const String updatedAtKey = 'widget_updated_at';

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
    await HomeWidget.updateWidget(
      androidName: providerName,
      qualifiedAndroidName: qualifiedProviderName,
    );
  }
}
