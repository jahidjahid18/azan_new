import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/models/app_settings.dart';
import 'package:azan_app/features/quran/data/models/quran_bookmark.dart';
import 'package:azan_app/features/quran/data/models/quran_reader_preferences.dart';
import 'package:azan_app/features/quran/data/models/quran_read_position.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  late final Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(AppConstants.hiveBoxName);
  }

  AppSettings loadSettings() {
    final stored = _box.get(AppConstants.settingsStorageKey);
    if (stored is Map) {
      return AppSettings.fromMap(Map<String, dynamic>.from(stored));
    }
    return AppSettings.defaults();
  }

  AppLocation? loadLocation() {
    final stored = _box.get(AppConstants.locationStorageKey);
    if (stored is Map) {
      return AppLocation.fromMap(Map<String, dynamic>.from(stored));
    }
    return null;
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(AppConstants.settingsStorageKey, settings.toMap());
  }

  Future<void> saveLocation(AppLocation location) async {
    await _box.put(AppConstants.locationStorageKey, location.toMap());
  }

  int loadTasbihCount() {
    final stored = _box.get(AppConstants.tasbihStorageKey);
    if (stored is int) {
      return stored;
    }
    return 0;
  }

  Future<void> saveTasbihCount(int count) async {
    await _box.put(AppConstants.tasbihStorageKey, count);
  }

  Map<String, dynamic> loadPrayerTracker() {
    final stored = _box.get(AppConstants.prayerTrackerStorageKey);
    if (stored is Map) {
      return Map<String, dynamic>.from(stored);
    }
    return <String, dynamic>{};
  }

  Future<void> savePrayerTracker(Map<String, dynamic> data) async {
    await _box.put(AppConstants.prayerTrackerStorageKey, data);
  }

  List<QuranBookmark> loadQuranBookmarks() {
    final stored = _box.get(AppConstants.quranBookmarksStorageKey);
    if (stored is List) {
      return stored
          .whereType<Map>()
          .map((item) => QuranBookmark.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }
    return <QuranBookmark>[];
  }

  Future<void> saveQuranBookmarks(List<QuranBookmark> bookmarks) async {
    await _box.put(
      AppConstants.quranBookmarksStorageKey,
      bookmarks.map((bookmark) => bookmark.toMap()).toList(),
    );
  }

  QuranReadPosition? loadQuranLastRead() {
    final stored = _box.get(AppConstants.quranLastReadStorageKey);
    if (stored is Map) {
      return QuranReadPosition.fromMap(Map<String, dynamic>.from(stored));
    }
    return null;
  }

  Future<void> saveQuranLastRead(QuranReadPosition position) async {
    await _box.put(AppConstants.quranLastReadStorageKey, position.toMap());
  }

  QuranReaderPreferences loadQuranReaderPreferences() {
    final stored = _box.get(AppConstants.quranReaderPrefsStorageKey);
    if (stored is Map) {
      return QuranReaderPreferences.fromMap(Map<String, dynamic>.from(stored));
    }
    return QuranReaderPreferences.defaults();
  }

  Future<void> saveQuranReaderPreferences(
    QuranReaderPreferences preferences,
  ) async {
    await _box.put(
      AppConstants.quranReaderPrefsStorageKey,
      preferences.toMap(),
    );
  }

  Map<String, dynamic> loadAzkarTracker() {
    final stored = _box.get(AppConstants.azkarTrackerStorageKey);
    if (stored is Map) {
      return Map<String, dynamic>.from(stored);
    }
    return <String, dynamic>{};
  }

  Future<void> saveAzkarTracker(Map<String, dynamic> data) async {
    await _box.put(AppConstants.azkarTrackerStorageKey, data);
  }

  Map<String, dynamic> dumpAllData() {
    return <String, dynamic>{
      'version': 1,
      AppConstants.settingsStorageKey:
          _box.get(AppConstants.settingsStorageKey) ?? <String, dynamic>{},
      AppConstants.locationStorageKey: _box.get(
        AppConstants.locationStorageKey,
      ),
      AppConstants.tasbihStorageKey:
          _box.get(AppConstants.tasbihStorageKey) ?? 0,
      AppConstants.prayerTrackerStorageKey:
          _box.get(AppConstants.prayerTrackerStorageKey) ?? <String, dynamic>{},
      AppConstants.quranBookmarksStorageKey:
          _box.get(AppConstants.quranBookmarksStorageKey) ?? <dynamic>[],
      AppConstants.quranLastReadStorageKey: _box.get(
        AppConstants.quranLastReadStorageKey,
      ),
      AppConstants.quranReaderPrefsStorageKey:
          _box.get(AppConstants.quranReaderPrefsStorageKey) ??
          <String, dynamic>{},
      AppConstants.azkarTrackerStorageKey:
          _box.get(AppConstants.azkarTrackerStorageKey) ?? <String, dynamic>{},
    };
  }

  Future<void> restoreAllData(Map<String, dynamic> backup) async {
    if (!backup.containsKey(AppConstants.settingsStorageKey)) {
      throw Exception('Invalid backup file.');
    }

    await _box.put(
      AppConstants.settingsStorageKey,
      backup[AppConstants.settingsStorageKey],
    );
    await _box.put(
      AppConstants.locationStorageKey,
      backup[AppConstants.locationStorageKey],
    );
    await _box.put(
      AppConstants.tasbihStorageKey,
      backup[AppConstants.tasbihStorageKey] ?? 0,
    );
    await _box.put(
      AppConstants.prayerTrackerStorageKey,
      backup[AppConstants.prayerTrackerStorageKey] ?? <String, dynamic>{},
    );
    await _box.put(
      AppConstants.quranBookmarksStorageKey,
      backup[AppConstants.quranBookmarksStorageKey] ?? <dynamic>[],
    );
    await _box.put(
      AppConstants.quranLastReadStorageKey,
      backup[AppConstants.quranLastReadStorageKey],
    );
    await _box.put(
      AppConstants.quranReaderPrefsStorageKey,
      backup[AppConstants.quranReaderPrefsStorageKey] ?? <String, dynamic>{},
    );
    await _box.put(
      AppConstants.azkarTrackerStorageKey,
      backup[AppConstants.azkarTrackerStorageKey] ?? <String, dynamic>{},
    );
  }
}
