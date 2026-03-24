import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/models/prayer_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings: initializationSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> schedulePrayerNotifications({
    required bool enabled,
    required NotificationSoundMode soundMode,
    required List<PrayerInfo> upcomingPrayers,
  }) async {
    await _plugin.cancelAllPendingNotifications();

    if (!enabled) {
      return;
    }

    var notificationId = 1000;
    for (final prayer in upcomingPrayers) {
      await _plugin.zonedSchedule(
        id: notificationId++,
        title: '${prayer.name} Prayer',
        body: 'It is time for ${prayer.name}.',
        scheduledDate: tz.TZDateTime.from(prayer.time, tz.local),
        notificationDetails: _detailsForSoundMode(soundMode),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  NotificationDetails _detailsForSoundMode(NotificationSoundMode soundMode) {
    switch (soundMode) {
      case NotificationSoundMode.notificationOnly:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelIdSilent,
            AppConstants.notificationChannelName,
            channelDescription: 'Silent prayer notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: false,
            enableVibration: false,
          ),
          iOS: DarwinNotificationDetails(presentSound: false),
        );
      case NotificationSoundMode.azanSound:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelIdAzan,
            AppConstants.notificationChannelName,
            channelDescription: 'Prayer notifications with azan',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('azan'),
          ),
          iOS: DarwinNotificationDetails(presentSound: true),
        );
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }
}
