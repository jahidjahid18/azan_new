import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/models/prayer_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final DateFormat _timeFormat = DateFormat('h:mm a');

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
    required String locationName,
  }) async {
    await _cancelInIdRange(
      AppConstants.prayerNotificationIdStart,
      AppConstants.prayerNotificationIdEnd,
    );

    if (!enabled) {
      return;
    }

    var notificationId = AppConstants.prayerNotificationIdStart;
    for (var index = 0; index < upcomingPrayers.length; index++) {
      if (notificationId > AppConstants.prayerNotificationIdEnd) {
        break;
      }

      final prayer = upcomingPrayers[index];
      final nextPrayer = index + 1 < upcomingPrayers.length
          ? upcomingPrayers[index + 1]
          : null;
      final currentPrayerLabel =
          '${prayer.name} - ${_timeFormat.format(prayer.time)}';
      final nextPrayerLabel = nextPrayer == null
          ? '--'
          : '${nextPrayer.name} - ${_timeFormat.format(nextPrayer.time)}';
      final countdownLabel = nextPrayer == null
          ? '--:--:--'
          : _formatCountdown(nextPrayer.time.difference(prayer.time));

      final styleInformation = InboxStyleInformation(
        <String>[
          'Location: $locationName',
          '',
          'Next Prayer:',
          nextPrayerLabel,
          'Starts in: $countdownLabel',
        ],
        contentTitle: currentPrayerLabel,
        summaryText: 'Prayer Reminder',
      );

      await _plugin.zonedSchedule(
        id: notificationId++,
        title: currentPrayerLabel,
        body:
            'Location: $locationName | Next: $nextPrayerLabel | Starts in: $countdownLabel',
        scheduledDate: tz.TZDateTime.from(prayer.time, tz.local),
        notificationDetails: _detailsForSoundMode(
          soundMode,
          styleInformation: styleInformation,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> schedulePrePrayerReminderNotifications({
    required bool enabled,
    required NotificationSoundMode soundMode,
    required List<PrayerInfo> upcomingPrayers,
    required String locationName,
    int minutesBefore = 10,
  }) async {
    await _cancelInIdRange(
      AppConstants.prayerReminderNotificationIdStart,
      AppConstants.prayerReminderNotificationIdEnd,
    );

    if (!enabled) {
      return;
    }

    var notificationId = AppConstants.prayerReminderNotificationIdStart;
    final now = DateTime.now();

    for (final prayer in upcomingPrayers) {
      if (notificationId > AppConstants.prayerReminderNotificationIdEnd) {
        break;
      }

      final reminderAt = prayer.time.subtract(Duration(minutes: minutesBefore));
      if (!reminderAt.isAfter(now)) {
        continue;
      }

      await _plugin.zonedSchedule(
        id: notificationId++,
        title: '${prayer.name} in $minutesBefore min',
        body: 'Reminder: ${prayer.name} at ${_timeFormat.format(prayer.time)}',
        scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
        notificationDetails: _detailsForSoundMode(
          soundMode,
          styleInformation: InboxStyleInformation(
            <String>[
              'Location: $locationName',
              'Prayer: ${prayer.name}',
              'Time: ${_timeFormat.format(prayer.time)}',
            ],
            contentTitle: '${prayer.name} reminder',
            summaryText: 'Prayer starts soon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> scheduleDailyAyahNotification({
    required bool enabled,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    await _plugin.cancel(id: AppConstants.dailyAyahNotificationId);
    if (!enabled) {
      return;
    }

    final scheduledDate = _nextOccurrence(time);
    await _plugin.zonedSchedule(
      id: AppConstants.dailyAyahNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.retentionChannelId,
          AppConstants.retentionChannelName,
          channelDescription: 'Daily ayah and engagement reminders',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          ongoing: false,
          autoCancel: true,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleEngagementReminderForNextDay({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    await _plugin.cancel(id: AppConstants.engagementReminderNotificationId);
    if (!enabled) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      time.hour,
      time.minute,
    );

    await _plugin.zonedSchedule(
      id: AppConstants.engagementReminderNotificationId,
      title: 'Come back today',
      body: 'You have not opened the app today. Continue your daily worship.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.retentionChannelId,
          AppConstants.retentionChannelName,
          channelDescription: 'Daily ayah and engagement reminders',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          ongoing: false,
          autoCancel: true,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  NotificationDetails _detailsForSoundMode(
    NotificationSoundMode soundMode, {
    required StyleInformation styleInformation,
  }) {
    switch (soundMode) {
      case NotificationSoundMode.notificationOnly:
        return NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelIdSilent,
            AppConstants.notificationChannelName,
            channelDescription: 'Silent prayer notifications',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            styleInformation: styleInformation,
            visibility: NotificationVisibility.public,
            playSound: false,
            enableVibration: false,
            ongoing: false,
            autoCancel: true,
          ),
          iOS: const DarwinNotificationDetails(presentSound: false),
        );
      case NotificationSoundMode.azanSound:
        return NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelIdAzan,
            AppConstants.notificationChannelName,
            channelDescription: 'Prayer notifications with azan',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            styleInformation: styleInformation,
            visibility: NotificationVisibility.public,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('azan'),
            ongoing: false,
            autoCancel: true,
          ),
          iOS: const DarwinNotificationDetails(presentSound: true),
        );
    }
  }

  String _formatCountdown(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _cancelInIdRange(int start, int end) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= start && request.id <= end) {
        await _plugin.cancel(id: request.id);
      }
    }
  }

  tz.TZDateTime _nextOccurrence(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
