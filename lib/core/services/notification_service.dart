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
    required Map<String, Map<String, bool>> completionByDate,
    required Map<String, int> prayerOffsetsMinutes,
  }) async {
    await _plugin.cancelAllPendingNotifications();

    if (!enabled) {
      return;
    }

    var notificationId = 1000;
    final now = DateTime.now();

    for (final prayer in upcomingPrayers) {
      final offset = prayerOffsetsMinutes[prayer.name] ?? 0;
      final adjustedPrayerTime = prayer.time.add(Duration(minutes: offset));
      final dateKey = _dateKey(adjustedPrayerTime);
      final isCompleted = completionByDate[dateKey]?[prayer.name] ?? false;
      if (isCompleted) {
        continue;
      }

      final preReminderTime = adjustedPrayerTime.subtract(
        const Duration(minutes: AppConstants.reminderBeforeMinutes),
      );
      if (preReminderTime.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: notificationId++,
          title: '${prayer.name} in ${AppConstants.reminderBeforeMinutes} min',
          body: 'Prepare for ${prayer.name} prayer.',
          scheduledDate: tz.TZDateTime.from(preReminderTime, tz.local),
          notificationDetails: _detailsForSoundMode(
            NotificationSoundMode.notificationOnly,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }

      await _plugin.zonedSchedule(
        id: notificationId++,
        title: '${prayer.name} Prayer',
        body: 'It is time for ${prayer.name}.',
        scheduledDate: tz.TZDateTime.from(adjustedPrayerTime, tz.local),
        notificationDetails: _detailsForSoundMode(soundMode),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      final followUpTime = adjustedPrayerTime.add(
        const Duration(minutes: AppConstants.followUpReminderMinutes),
      );
      if (followUpTime.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: notificationId++,
          title: '${prayer.name} Check-in',
          body: 'If prayed, mark ${prayer.name} as complete in Tracker.',
          scheduledDate: tz.TZDateTime.from(followUpTime, tz.local),
          notificationDetails: _detailsForSoundMode(
            NotificationSoundMode.notificationOnly,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
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
