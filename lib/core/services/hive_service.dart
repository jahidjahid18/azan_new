import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/models/app_settings.dart';
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
}
