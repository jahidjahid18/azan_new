class AppConstants {
  static const String appTitle = 'Azan';

  static const String hiveBoxName = 'azan_box';
  static const String settingsStorageKey = 'settings';
  static const String locationStorageKey = 'location';
  static const String tasbihStorageKey = 'tasbih_count';
  static const String prayerTrackerStorageKey = 'prayer_tracker';

  static const int notificationHorizonDays = 30;

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
