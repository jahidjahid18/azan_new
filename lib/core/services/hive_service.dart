import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/models/app_settings.dart';
import 'package:azan_app/features/azkar/data/models/saved_azkar_item.dart';
import 'package:azan_app/features/daily/data/models/saved_daily_item.dart';
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
    if (stored is! List) {
      return <QuranBookmark>[];
    }

    return stored
        .whereType<Map>()
        .map((item) => QuranBookmark.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> saveQuranBookmarks(List<QuranBookmark> bookmarks) async {
    await _box.put(
      AppConstants.quranBookmarksStorageKey,
      bookmarks.map((bookmark) => bookmark.toMap()).toList(growable: false),
    );
  }

  QuranReadPosition? loadQuranLastRead() {
    final stored = _box.get(AppConstants.quranLastReadStorageKey);
    if (stored is Map) {
      return QuranReadPosition.fromMap(Map<String, dynamic>.from(stored));
    }
    return null;
  }

  Future<void> saveQuranLastRead(QuranReadPosition lastRead) async {
    await _box.put(AppConstants.quranLastReadStorageKey, lastRead.toMap());
  }

  Map<String, dynamic> loadAzkarTracker() {
    final stored = _box.get(AppConstants.azkarTrackerStorageKey);
    if (stored is Map) {
      return Map<String, dynamic>.from(stored);
    }
    return <String, dynamic>{};
  }

  Future<void> saveAzkarTracker(Map<String, dynamic> tracker) async {
    await _box.put(AppConstants.azkarTrackerStorageKey, tracker);
  }

  List<SavedDailyItem> loadDailyFavorites() {
    final stored = _box.get(AppConstants.dailyFavoritesStorageKey);
    if (stored is! List) {
      return <SavedDailyItem>[];
    }

    return stored
        .whereType<Map>()
        .map((item) => SavedDailyItem.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> saveDailyFavorites(List<SavedDailyItem> items) async {
    await _box.put(
      AppConstants.dailyFavoritesStorageKey,
      items.map((item) => item.toMap()).toList(growable: false),
    );
  }

  List<SavedAzkarItem> loadAzkarFavorites() {
    final stored = _box.get(AppConstants.azkarFavoritesStorageKey);
    if (stored is! List) {
      return <SavedAzkarItem>[];
    }

    return stored
        .whereType<Map>()
        .map((item) => SavedAzkarItem.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> saveAzkarFavorites(List<SavedAzkarItem> items) async {
    await _box.put(
      AppConstants.azkarFavoritesStorageKey,
      items.map((item) => item.toMap()).toList(growable: false),
    );
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
}
