class AppConstants {
  static const String appTitle = 'Azan';

  static const String hiveBoxName = 'azan_box';
  static const String settingsStorageKey = 'settings';
  static const String locationStorageKey = 'location';
  static const String tasbihStorageKey = 'tasbih_count';
  static const String prayerTrackerStorageKey = 'prayer_tracker';
  static const String quranBookmarksStorageKey = 'quran_bookmarks';
  static const String quranLastReadStorageKey = 'quran_last_read';
  static const String azkarTrackerStorageKey = 'azkar_tracker';
  static const String dailyFavoritesStorageKey = 'daily_favorites';
  static const String azkarFavoritesStorageKey = 'azkar_favorites';
  static const String quranReaderPrefsStorageKey = 'quran_reader_prefs';

  static const int notificationHorizonDays = 30;
  static const int reminderBeforeMinutes = 15;
  static const int followUpReminderMinutes = 25;

  static const String notificationChannelIdSilent = 'prayer_silent_channel';
  static const String notificationChannelIdAzan = 'prayer_azan_channel';
  static const String notificationChannelName = 'Prayer Alerts';

  static const List<String> prayerOrder = <String>[
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];
}
