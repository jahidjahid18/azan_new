import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/models/offline_city.dart';
import 'package:azan_app/core/models/app_settings.dart';
import 'package:azan_app/core/models/prohibited_time.dart';
import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/services/hive_service.dart';
import 'package:azan_app/core/services/location_service.dart';
import 'package:azan_app/core/services/location_sqlite_service.dart';
import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_notification_scheduler.dart';
import 'package:azan_app/core/services/prayer_service.dart';
import 'package:azan_app/core/services/quran_reading_sqlite_service.dart';
import 'package:azan_app/features/daily/data/daily_content_service.dart';
import 'package:azan_app/features/daily/data/models/daily_content_item.dart';
import 'package:azan_app/features/quran/data/models/quran_bookmark.dart';
import 'package:azan_app/features/quran/data/models/quran_reader_preferences.dart';
import 'package:azan_app/features/quran/data/models/quran_read_position.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  AppController({
    required HiveService hiveService,
    required LocationService locationService,
    required LocationSqliteService locationSqliteService,
    required QuranReadingSqliteService quranReadingSqliteService,
    required PrayerService prayerService,
    required NotificationService notificationService,
    required PrayerNotificationScheduler prayerNotificationScheduler,
    required DailyContentService dailyContentService,
  }) : _hiveService = hiveService,
       _locationService = locationService,
       _locationSqliteService = locationSqliteService,
       _quranReadingSqliteService = quranReadingSqliteService,
       _prayerService = prayerService,
       _notificationService = notificationService,
       _prayerNotificationScheduler = prayerNotificationScheduler,
       _dailyContentService = dailyContentService;

  final HiveService _hiveService;
  final LocationService _locationService;
  final LocationSqliteService _locationSqliteService;
  final QuranReadingSqliteService _quranReadingSqliteService;
  final PrayerService _prayerService;
  final NotificationService _notificationService;
  final PrayerNotificationScheduler _prayerNotificationScheduler;
  final DailyContentService _dailyContentService;

  AppSettings _settings = AppSettings.defaults();
  AppLocation? _location;
  List<PrayerInfo> _todayPrayers = <PrayerInfo>[];
  List<ProhibitedTime> _todayProhibitedTimes = <ProhibitedTime>[];
  PrayerInfo? _nextPrayer;
  Duration _nextPrayerCountdown = Duration.zero;

  DateTime _now = DateTime.now();
  Timer? _ticker;
  int _tasbihCount = 0;
  DailyContentItem? _dailyContent;
  Map<String, dynamic> _prayerTracker = <String, dynamic>{};
  List<QuranBookmark> _quranBookmarks = <QuranBookmark>[];
  QuranReadPosition? _quranLastRead;
  int _quranReadingTodaySeconds = 0;
  String _quranReadingDateKey = '';
  QuranReaderPreferences _quranReaderPreferences =
      QuranReaderPreferences.defaults();
  Map<String, dynamic> _azkarTracker = <String, dynamic>{};

  bool _isLoading = true;
  bool _isBusy = false;
  String? _startupError;

  AppSettings get settings => _settings;
  AppLocation? get location => _location;
  List<PrayerInfo> get todayPrayers => _todayPrayers;
  List<ProhibitedTime> get todayProhibitedTimes => _todayProhibitedTimes;
  PrayerInfo? get nextPrayer => _nextPrayer;
  Duration get nextPrayerCountdown => _nextPrayerCountdown;
  DateTime get now => _now;
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  String? get startupError => _startupError;
  int get tasbihCount => _tasbihCount;
  DailyContentItem? get dailyContent => _dailyContent;
  ThemeModeOption get themeMode => _settings.themeMode;
  ThemeStyleOption get themeStyle => _settings.themeStyle;
  AppLanguage get appLanguage => _settings.appLanguage;
  Locale get locale => _settings.appLanguage.locale;
  List<String> get visiblePrayerNames => _settings.visiblePrayerNames;
  bool get showProhibitedTimes => _settings.showProhibitedTimes;
  bool isNowProhibited(DateTime now) {
    return _prayerService.isNowProhibited(
      now: now,
      prohibitedTimes: _todayProhibitedTimes,
    );
  }

  List<QuranBookmark> get quranBookmarks =>
      List<QuranBookmark>.unmodifiable(_quranBookmarks);
  QuranReadPosition? get quranLastRead => _quranLastRead;
  int get quranReadingTodaySeconds => _quranReadingTodaySeconds;
  int get quranReadingTodayMinutes => _quranReadingTodaySeconds ~/ 60;
  QuranReaderPreferences get quranReaderPreferences => _quranReaderPreferences;

  Future<void> initialize() async {
    try {
      await _hiveService.init();
      try {
        await _notificationService.initialize();
      } catch (_) {
        // Notifications are optional for UI timing; keep app startup resilient.
      }

      _settings = _hiveService.loadSettings();
      await _migrateDefaultVisiblePrayersIfNeeded();
      final hiveLocation = _hiveService.loadLocation();
      _location = hiveLocation ?? await _locationSqliteService.loadLocation();
      if (hiveLocation == null && _location != null) {
        await _hiveService.saveLocation(_location!);
      }
      _tasbihCount = _hiveService.loadTasbihCount();
      _prayerTracker = _hiveService.loadPrayerTracker();
      _quranBookmarks = _hiveService.loadQuranBookmarks();
      _quranLastRead = _hiveService.loadQuranLastRead();
      await _syncQuranLastReadFromSqlite();
      await _loadQuranReadingTodayFromSqlite();
      _quranReaderPreferences = _hiveService.loadQuranReaderPreferences();
      _azkarTracker = _hiveService.loadAzkarTracker();

      if (_location == null) {
        await _setLocationFromGps(showErrorsAsStartupError: true);
      }

      _recalculatePrayers();
      _dailyContent = await _dailyContentService.getContentForDate(_now);
      await _refreshNotificationSchedule();
      _startTickerIfNeeded();
    } catch (_) {
      _startupError =
          'Could not complete app setup. Please check permissions and try again.';
    } finally {
      // Ensure the app clock keeps ticking even if optional startup tasks fail.
      _startTickerIfNeeded();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _migrateDefaultVisiblePrayersIfNeeded() async {
    final migratedV2 = _hiveService.loadBool(
      key: AppConstants.visiblePrayersMigratedV2StorageKey,
      defaultValue: false,
    );
    if (migratedV2) {
      return;
    }

    final migrated = _hiveService.loadBool(
      key: AppConstants.visiblePrayersMigratedStorageKey,
      defaultValue: false,
    );
    final currentSet = _settings.visiblePrayerNames.toSet();
    final mandatorySet = AppConstants.mandatoryPrayerNames.toSet();
    final isLegacyDefault =
        currentSet.length == mandatorySet.length &&
        currentSet.containsAll(mandatorySet);

    if (isLegacyDefault) {
      _settings = _settings.copyWith(
        visiblePrayerNames: AppConstants.defaultVisiblePrayerNames,
      );
      await _hiveService.saveSettings(_settings);
    }
    if (!migrated) {
      await _hiveService.saveBool(
        key: AppConstants.visiblePrayersMigratedStorageKey,
        value: true,
      );
    }
    await _hiveService.saveBool(
      key: AppConstants.visiblePrayersMigratedV2StorageKey,
      value: true,
    );
  }

  Future<String?> refreshLocationFromGps() async {
    return _runBusyAction(() async {
      await _setLocationFromGps(showErrorsAsStartupError: false);
      _recalculatePrayers();
      await _refreshNotificationSchedule();
      _startTickerIfNeeded();
    });
  }

  Future<String?> saveManualLocation({
    required String latitudeText,
    required String longitudeText,
    required String cityText,
  }) {
    return _runBusyAction(() async {
      final latitude = double.tryParse(latitudeText.trim());
      final longitude = double.tryParse(longitudeText.trim());

      if (latitude == null || longitude == null) {
        throw const LocationException(
          'Latitude and longitude must be numbers.',
        );
      }
      if (latitude < -90 || latitude > 90) {
        throw const LocationException('Latitude must be between -90 and 90.');
      }
      if (longitude < -180 || longitude > 180) {
        throw const LocationException(
          'Longitude must be between -180 and 180.',
        );
      }

      _location = await _locationService.fromManualCoordinates(
        latitude: latitude,
        longitude: longitude,
        cityName: cityText,
      );
      await _persistLocation(_location!);

      _recalculatePrayers();
      await _refreshNotificationSchedule();
      _startTickerIfNeeded();
    });
  }

  Future<String?> saveOfflineCityLocation(OfflineCity city) {
    return _runBusyAction(() async {
      final cityName = '${city.name}, ${city.country}';
      _location = AppLocation(
        latitude: city.latitude,
        longitude: city.longitude,
        cityName: cityName,
      );
      await _persistLocation(_location!);
      _recalculatePrayers();
      await _refreshNotificationSchedule();
      _startTickerIfNeeded();
    });
  }

  Future<void> updateCalculationMethod(CalculationMethodOption method) async {
    _settings = _settings.copyWith(calculationMethod: method);
    await _hiveService.saveSettings(_settings);
    _recalculatePrayers();
    await _refreshNotificationSchedule();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _hiveService.saveSettings(_settings);
    await _refreshNotificationSchedule();
    notifyListeners();
  }

  Future<void> setNotificationSoundMode(NotificationSoundMode mode) async {
    _settings = _settings.copyWith(notificationSoundMode: mode);
    await _hiveService.saveSettings(_settings);
    await _refreshNotificationSchedule();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemeStyle(ThemeStyleOption style) async {
    _settings = _settings.copyWith(themeStyle: style);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAppLanguage(AppLanguage language) async {
    _settings = _settings.copyWith(appLanguage: language);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setVisiblePrayerNames(List<String> names) async {
    final valid = names
        .where(
          (name) =>
              AppConstants.mandatoryPrayerNames.contains(name) ||
              AppConstants.optionalPrayerNames.contains(name),
        )
        .toSet()
        .toList();
    if (valid.isEmpty) {
      return;
    }
    _settings = _settings.copyWith(visiblePrayerNames: valid);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setShowProhibitedTimes(bool enabled) async {
    _settings = _settings.copyWith(showProhibitedTimes: enabled);
    await _hiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<String?> exportBackup({required String filePath}) {
    return _runBusyAction(() async {
      final backupData = _hiveService.dumpAllData();
      final file = File(filePath);
      await file.writeAsString(jsonEncode(backupData));
    });
  }

  Future<String?> importBackup({required String filePath}) {
    return _runBusyAction(() async {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found.');
      }

      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid backup format.');
      }

      await _hiveService.restoreAllData(decoded);
      await _reloadStateFromStorage();
      _recalculatePrayers();
      await _refreshNotificationSchedule();
      _startTickerIfNeeded();
    });
  }

  bool isQuranBookmarked({required int surahNumber, required int ayahNumber}) {
    return _quranBookmarks.any(
      (bookmark) =>
          bookmark.surahNumber == surahNumber &&
          bookmark.ayahNumber == ayahNumber,
    );
  }

  Future<void> toggleQuranBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
  }) async {
    final existingIndex = _quranBookmarks.indexWhere(
      (bookmark) =>
          bookmark.surahNumber == surahNumber &&
          bookmark.ayahNumber == ayahNumber,
    );

    if (existingIndex >= 0) {
      _quranBookmarks.removeAt(existingIndex);
    } else {
      _quranBookmarks.add(
        QuranBookmark(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          surahName: surahName,
        ),
      );
      _quranBookmarks.sort((a, b) {
        final surahCompare = a.surahNumber.compareTo(b.surahNumber);
        if (surahCompare != 0) return surahCompare;
        return a.ayahNumber.compareTo(b.ayahNumber);
      });
    }

    await _hiveService.saveQuranBookmarks(_quranBookmarks);
    notifyListeners();
  }

  Future<void> setQuranLastRead({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    _quranLastRead = QuranReadPosition(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    await _hiveService.saveQuranLastRead(_quranLastRead!);
    try {
      await _quranReadingSqliteService.saveLastReadPosition(_quranLastRead!);
    } catch (_) {
      // Preserve reader flow even if optional SQLite write fails.
    }
    notifyListeners();
  }

  Future<void> addQuranReadingActiveSeconds(int seconds) async {
    if (seconds <= 0) return;

    final todayKey = _dateKey(DateTime.now());
    if (_quranReadingDateKey != todayKey) {
      await _loadQuranReadingTodayFromSqlite();
    }

    _quranReadingTodaySeconds += seconds;
    notifyListeners();

    try {
      await _quranReadingSqliteService.incrementActiveSecondsForDate(
        dateKey: _quranReadingDateKey,
        seconds: seconds,
      );
    } catch (_) {
      // SQLite write failure should not block app usage.
    }
  }

  Future<void> setQuranReaderPreferences(
    QuranReaderPreferences preferences,
  ) async {
    _quranReaderPreferences = preferences;
    await _hiveService.saveQuranReaderPreferences(preferences);
    notifyListeners();
  }

  Future<void> _setLocationFromGps({
    required bool showErrorsAsStartupError,
  }) async {
    try {
      _location = await _locationService.getCurrentLocation();
      await _persistLocation(_location!);
      _startupError = null;
    } catch (e) {
      if (showErrorsAsStartupError) {
        _startupError = e.toString();
      } else {
        rethrow;
      }
    }
  }

  void _recalculatePrayers() {
    _now = DateTime.now();

    if (_location == null) {
      _todayPrayers = <PrayerInfo>[];
      _todayProhibitedTimes = <ProhibitedTime>[];
      _nextPrayer = null;
      _nextPrayerCountdown = Duration.zero;
      return;
    }

    _todayPrayers = _prayerService.getDisplayTimesForDate(
      location: _location!,
      date: _now,
      calculationMethod: _settings.calculationMethod,
    );
    _todayProhibitedTimes = _prayerService.getProhibitedTimesForDate(
      location: _location!,
      date: _now,
      calculationMethod: _settings.calculationMethod,
    );
    final todayObligatoryPrayers = _todayPrayers
        .where((prayer) => prayer.isObligatory)
        .toList();

    _nextPrayer = _prayerService.getNextPrayer(
      location: _location!,
      now: _now,
      calculationMethod: _settings.calculationMethod,
      todayObligatoryPrayers: todayObligatoryPrayers,
    );
    _nextPrayerCountdown = _nextPrayer == null
        ? Duration.zero
        : _nextPrayer!.time.difference(_now);
  }

  Future<void> _refreshNotificationSchedule() async {
    try {
      await _prayerNotificationScheduler.schedule(
        enabled: _settings.notificationsEnabled,
        soundMode: _settings.notificationSoundMode,
        location: _location,
        calculationMethod: _settings.calculationMethod,
      );
    } catch (_) {
      // Keep core app flows active even if OS scheduling fails temporarily.
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final previousDate = DateTime(_now.year, _now.month, _now.day);

      _now = DateTime.now();
      _nextPrayerCountdown = _nextPrayer == null
          ? Duration.zero
          : _nextPrayer!.time.difference(_now);

      final currentDate = DateTime(_now.year, _now.month, _now.day);
      if (currentDate.isAfter(previousDate) ||
          _nextPrayerCountdown.isNegative) {
        _recalculatePrayers();
        if (currentDate.isAfter(previousDate)) {
          unawaited(_refreshDailyContent());
          unawaited(_refreshNotificationSchedule());
          unawaited(_loadQuranReadingTodayFromSqlite(notify: false));
        }
      }

      notifyListeners();
    });
  }

  void _startTickerIfNeeded() {
    if (_ticker == null) {
      _startTicker();
    }
  }

  Future<String?> _runBusyAction(Future<void> Function() operation) async {
    if (_isBusy) {
      return 'Please wait for the current action to finish.';
    }

    try {
      _isBusy = true;
      notifyListeners();
      await operation();
      notifyListeners();
      return null;
    } on LocationException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> incrementTasbih() async {
    _tasbihCount += 1;
    await _hiveService.saveTasbihCount(_tasbihCount);
    notifyListeners();
  }

  Future<void> resetTasbih() async {
    _tasbihCount = 0;
    await _hiveService.saveTasbihCount(_tasbihCount);
    notifyListeners();
  }

  Map<String, int> azkarCountsForDateCategory({
    required DateTime date,
    required String category,
  }) {
    final key = _dateKey(date);
    final dayRaw = _azkarTracker[key];
    if (dayRaw is! Map) {
      return <String, int>{};
    }

    final dayMap = Map<String, dynamic>.from(dayRaw);
    final categoryRaw = dayMap[category];
    if (categoryRaw is! Map) {
      return <String, int>{};
    }

    return Map<String, dynamic>.from(
      categoryRaw,
    ).map((k, v) => MapEntry(k, v as int? ?? 0));
  }

  Future<void> incrementAzkarCount({
    required DateTime date,
    required String category,
    required String itemId,
    required int maxCount,
  }) async {
    final key = _dateKey(date);
    final dayMap = Map<String, dynamic>.from(
      _azkarTracker[key] as Map? ?? <String, dynamic>{},
    );
    final categoryMap = Map<String, dynamic>.from(
      dayMap[category] as Map? ?? <String, dynamic>{},
    );
    final current = categoryMap[itemId] as int? ?? 0;
    categoryMap[itemId] = current >= maxCount ? maxCount : current + 1;
    dayMap[category] = categoryMap;
    _azkarTracker[key] = dayMap;
    await _hiveService.saveAzkarTracker(_azkarTracker);
    notifyListeners();
  }

  Future<void> resetAzkarCategory({
    required DateTime date,
    required String category,
  }) async {
    final key = _dateKey(date);
    final dayMap = Map<String, dynamic>.from(
      _azkarTracker[key] as Map? ?? <String, dynamic>{},
    );
    dayMap[category] = <String, dynamic>{};
    _azkarTracker[key] = dayMap;
    await _hiveService.saveAzkarTracker(_azkarTracker);
    notifyListeners();
  }

  Map<String, bool> prayerTrackerForDate(DateTime date) {
    final key = _dateKey(date);
    final data = _prayerTracker[key];
    if (data is! Map) {
      return <String, bool>{for (final p in AppConstants.prayerOrder) p: false};
    }

    final typed = Map<String, dynamic>.from(data);
    return <String, bool>{
      for (final prayer in AppConstants.prayerOrder)
        prayer: typed[prayer] as bool? ?? false,
    };
  }

  Future<void> setPrayerCompleted({
    required DateTime date,
    required String prayerName,
    required bool completed,
  }) async {
    final key = _dateKey(date);
    final current = prayerTrackerForDate(date);
    current[prayerName] = completed;
    _prayerTracker[key] = current;
    await _hiveService.savePrayerTracker(_prayerTracker);
    notifyListeners();
  }

  double todayPrayerCompletionPercent() {
    final today = prayerTrackerForDate(DateTime.now());
    final completedCount = today.values.where((value) => value).length;
    return completedCount / AppConstants.prayerOrder.length;
  }

  double weeklyPrayerCompletionPercent() {
    var total = 0;
    var completed = 0;

    for (var i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final tracker = prayerTrackerForDate(date);
      total += AppConstants.prayerOrder.length;
      completed += tracker.values.where((value) => value).length;
    }

    if (total == 0) return 0;
    return completed / total;
  }

  Future<void> _refreshDailyContent() async {
    _dailyContent = await _dailyContentService.getContentForDate(_now);
    notifyListeners();
  }

  Future<void> _reloadStateFromStorage() async {
    _settings = _hiveService.loadSettings();
    _location = _hiveService.loadLocation();
    _location ??= await _locationSqliteService.loadLocation();
    _tasbihCount = _hiveService.loadTasbihCount();
    _prayerTracker = _hiveService.loadPrayerTracker();
    _quranBookmarks = _hiveService.loadQuranBookmarks();
    _quranLastRead = _hiveService.loadQuranLastRead();
    await _syncQuranLastReadFromSqlite();
    await _loadQuranReadingTodayFromSqlite(notify: false);
    _quranReaderPreferences = _hiveService.loadQuranReaderPreferences();
    _azkarTracker = _hiveService.loadAzkarTracker();
    _dailyContent = await _dailyContentService.getContentForDate(
      DateTime.now(),
    );
  }

  Future<void> _persistLocation(AppLocation location) async {
    await _hiveService.saveLocation(location);
    try {
      await _locationSqliteService.saveLocation(location);
    } catch (_) {
      // Keep prayer workflows working even if SQLite write fails.
    }
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }

  Future<void> _syncQuranLastReadFromSqlite() async {
    try {
      final sqliteLastRead = await _quranReadingSqliteService
          .loadLastReadPosition();
      if (sqliteLastRead != null) {
        _quranLastRead = sqliteLastRead;
        await _hiveService.saveQuranLastRead(sqliteLastRead);
        return;
      }
      if (_quranLastRead != null) {
        await _quranReadingSqliteService.saveLastReadPosition(_quranLastRead!);
      }
    } catch (_) {
      // Last-read sync is best-effort.
    }
  }

  Future<void> _loadQuranReadingTodayFromSqlite({bool notify = false}) async {
    final dateKey = _dateKey(DateTime.now());
    _quranReadingDateKey = dateKey;
    try {
      _quranReadingTodaySeconds = await _quranReadingSqliteService
          .getActiveSecondsForDate(dateKey);
    } catch (_) {
      _quranReadingTodaySeconds = 0;
    }

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
