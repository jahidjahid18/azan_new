class AppConstants {
  static const String appTitle = 'Azan';

  static const String hiveBoxName = 'azan_box';
  static const String settingsStorageKey = 'settings';
  static const String locationStorageKey = 'location';
  static const String tasbihStorageKey = 'tasbih_count';
  static const String prayerTrackerStorageKey = 'prayer_tracker';
  static const String quranBookmarksStorageKey = 'quran_bookmarks';
  static const String quranLastReadStorageKey = 'quran_last_read';
  static const String quranReaderPrefsStorageKey = 'quran_reader_prefs';
  static const String dailyQuranAyahStateStorageKey = 'daily_quran_ayah_state';
  static const String azkarTrackerStorageKey = 'azkar_tracker';
  static const String visiblePrayersMigratedStorageKey =
      'visible_prayers_migrated_v1';
  static const String visiblePrayersMigratedV2StorageKey =
      'visible_prayers_migrated_v2_all_prayers_default';

  static const int notificationHorizonDays = 30;

  static const String notificationChannelIdSilent = 'prayer_silent_channel';
  static const String notificationChannelIdAzan = 'prayer_azan_channel';
  static const String notificationChannelName = 'Prayer Alerts';
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
