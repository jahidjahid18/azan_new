import 'dart:io';

import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_alarm_service.dart';
import 'package:azan_app/core/services/prayer_service.dart';

class PrayerNotificationScheduler {
  PrayerNotificationScheduler({
    required PrayerService prayerService,
    required NotificationService notificationService,
    required PrayerAlarmService prayerAlarmService,
  }) : _prayerService = prayerService,
       _notificationService = notificationService,
       _prayerAlarmService = prayerAlarmService;

  final PrayerService _prayerService;
  final NotificationService _notificationService;
  final PrayerAlarmService _prayerAlarmService;

  Future<void> schedule({
    required bool enabled,
    required NotificationSoundMode soundMode,
    required AppLocation? location,
    required CalculationMethodOption calculationMethod,
  }) async {
    if (!enabled || location == null) {
      await _prayerAlarmService.cancelPrayerAlarms();
      await _notificationService.schedulePrayerNotifications(
        enabled: false,
        soundMode: soundMode,
        upcomingPrayers: const [],
        locationName: 'Unknown location',
      );
      await _notificationService.schedulePrePrayerReminderNotifications(
        enabled: false,
        soundMode: soundMode,
        upcomingPrayers: const [],
        locationName: 'Unknown location',
        minutesBefore: 10,
      );
      return;
    }

    final upcomingPrayers = _prayerService.getUpcomingPrayers(
      location: location,
      calculationMethod: calculationMethod,
      numberOfDays: AppConstants.notificationHorizonDays,
    );

    if (Platform.isAndroid) {
      try {
        await _prayerAlarmService.schedulePrayerAlarms(
          enabled: true,
          soundMode: soundMode,
          upcomingPrayers: upcomingPrayers,
          locationName: location.cityName,
        );

        // Prevent duplicate notifications from plugin schedules on Android.
        await _notificationService.schedulePrayerNotifications(
          enabled: false,
          soundMode: soundMode,
          upcomingPrayers: const [],
          locationName: location.cityName,
        );
        await _notificationService.schedulePrePrayerReminderNotifications(
          enabled: false,
          soundMode: soundMode,
          upcomingPrayers: const [],
          locationName: location.cityName,
          minutesBefore: 10,
        );
        return;
      } catch (_) {
        // Fall back to plugin schedules if native scheduling fails.
      }
    }

    // Non-Android (or fallback): keep existing plugin-based behavior.
    await _notificationService.schedulePrayerNotifications(
      enabled: true,
      soundMode: soundMode,
      upcomingPrayers: upcomingPrayers,
      locationName: location.cityName,
    );
    await _notificationService.schedulePrePrayerReminderNotifications(
      enabled: true,
      soundMode: soundMode,
      upcomingPrayers: upcomingPrayers,
      locationName: location.cityName,
      minutesBefore: 10,
    );
  }
}
