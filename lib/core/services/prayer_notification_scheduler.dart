import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_service.dart';

class PrayerNotificationScheduler {
  PrayerNotificationScheduler({
    required PrayerService prayerService,
    required NotificationService notificationService,
  }) : _prayerService = prayerService,
       _notificationService = notificationService;

  final PrayerService _prayerService;
  final NotificationService _notificationService;

  Future<void> schedule({
    required bool enabled,
    required NotificationSoundMode soundMode,
    required AppLocation? location,
    required CalculationMethodOption calculationMethod,
  }) async {
    if (!enabled || location == null) {
      await _notificationService.schedulePrayerNotifications(
        enabled: false,
        soundMode: soundMode,
        upcomingPrayers: const [],
        locationName: 'Unknown location',
      );
      return;
    }

    final upcomingPrayers = _prayerService.getUpcomingPrayers(
      location: location,
      calculationMethod: calculationMethod,
      numberOfDays: AppConstants.notificationHorizonDays,
    );

    await _notificationService.schedulePrayerNotifications(
      enabled: true,
      soundMode: soundMode,
      upcomingPrayers: upcomingPrayers,
      locationName: location.cityName,
    );
  }
}
