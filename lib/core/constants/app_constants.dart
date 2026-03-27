class AppConstants {
  static const String appTitle = 'Azan';

  static const String hiveBoxName = 'azan_box';
  static const String settingsStorageKey = 'settings';
  static const String locationStorageKey = 'location';
  static const String tasbihStorageKey = 'tasbih_count';
  static const String tasbihGuidedProgressStorageKey =
      'tasbih_guided_progress';
  static const String prayerTrackerStorageKey = 'prayer_tracker';
  static const String quranBookmarksStorageKey = 'quran_bookmarks';
  static const String quranLastReadStorageKey = 'quran_last_read';
  static const String quranReaderPrefsStorageKey = 'quran_reader_prefs';
  static const String dailyQuranAyahStateStorageKey = 'daily_quran_ayah_state';
  static const String azkarTrackerStorageKey = 'azkar_tracker';
  static const String retentionLastOpenDateStorageKey =
      'retention_last_open_date';
  static const String retentionCurrentStreakStorageKey =
      'retention_current_streak';
  static const String dailyTasbihTrackerStorageKey = 'daily_tasbih_tracker';
  static const String retentionNotificationsEnabledStorageKey =
      'retention_notifications_enabled';
  static const String dailyAyahNotificationTimeStorageKey =
      'daily_ayah_notification_time';
  static const String engagementReminderTimeStorageKey =
      'engagement_reminder_time';
  static const String visiblePrayersMigratedStorageKey =
      'visible_prayers_migrated_v1';
  static const String visiblePrayersMigratedV2StorageKey =
      'visible_prayers_migrated_v2_all_prayers_default';

  static const int notificationHorizonDays = 30;

  static const String notificationChannelIdSilent = 'prayer_silent_channel';
  static const String notificationChannelIdAzan = 'prayer_azan_channel';
  static const String notificationChannelName = 'Prayer Alerts';
  static const String retentionChannelId = 'retention_daily_channel';
  static const String retentionChannelName = 'Daily Engagement';

  static const int prayerNotificationIdStart = 1000;
  static const int prayerNotificationIdEnd = 1999;
  static const int prayerReminderNotificationIdStart = 2000;
  static const int prayerReminderNotificationIdEnd = 2999;
  static const int dailyAyahNotificationId = 3001;
  static const int engagementReminderNotificationId = 3002;
  static const String developerSupportEmail = 'jahidjahid18@gmail.com';

  static const List<String> prayerOrder = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static const List<String> mandatoryPrayerNames = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static const List<String> optionalPrayerNames = <String>[
    'Imsak',
    'Qiyam',
    'Midnight',
  ];

  static const List<String> defaultVisiblePrayerNames = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
    'Imsak',
    'Qiyam',
    'Midnight',
  ];
}
