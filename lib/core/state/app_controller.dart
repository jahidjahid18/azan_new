import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/models/app_settings.dart';
import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/services/hive_service.dart';
import 'package:azan_app/core/services/location_service.dart';
import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_service.dart';
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
    required PrayerService prayerService,
    required NotificationService notificationService,
    required DailyContentService dailyContentService,
  }) : _hiveService = hiveService,
       _locationService = locationService,
       _prayerService = prayerService,
       _notificationService = notificationService,
       _dailyContentService = dailyContentService;

  final HiveService _hiveService;
  final LocationService _locationService;
  final PrayerService _prayerService;
  final NotificationService _notificationService;
  final DailyContentService _dailyContentService;

  AppSettings _settings = AppSettings.defaults();
  AppLocation? _location;
  List<PrayerInfo> _todayPrayers = <PrayerInfo>[];
  PrayerInfo? _nextPrayer;
  Duration _nextPrayerCountdown = Duration.zero;

  DateTime _now = DateTime.now();
  Timer? _ticker;
  int _tasbihCount = 0;
  DailyContentItem? _dailyContent;
  Map<String, dynamic> _prayerTracker = <String, dynamic>{};
  List<QuranBookmark> _quranBookmarks = <QuranBookmark>[];
  QuranReadPosition? _quranLastRead;
  QuranReaderPreferences _quranReaderPreferences =
      QuranReaderPreferences.defaults();
  Map<String, dynamic> _azkarTracker = <String, dynamic>{};

  bool _isLoading = true;
  bool _isBusy = false;
  String? _startupError;

  AppSettings get settings => _settings;
  AppLocation? get location => _location;
  List<PrayerInfo> get todayPrayers => _todayPrayers;
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
  List<QuranBookmark> get quranBookmarks =>
      List<QuranBookmark>.unmodifiable(_quranBookmarks);
  QuranReadPosition? get quranLastRead => _quranLastRead;
  QuranReaderPreferences get quranReaderPreferences => _quranReaderPreferences;

  Future<void> initialize() async {
    try {
      await _hiveService.init();
      await _notificationService.initialize();

      _settings = _hiveService.loadSettings();
      if (_settings.themeStyle == ThemeStyleOption.glassBlue) {
        _settings = _settings.copyWith(themeStyle: ThemeStyleOption.muslimPro);
        await _hiveService.saveSettings(_settings);
      }
      _location = _hiveService.loadLocation();
      _tasbihCount = _hiveService.loadTasbihCount();
      _prayerTracker = _hiveService.loadPrayerTracker();
      _quranBookmarks = _hiveService.loadQuranBookmarks();
      _quranLastRead = _hiveService.loadQuranLastRead();
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
      _isLoading = false;
      notifyListeners();
    }
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
      await _hiveService.saveLocation(_location!);

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
    notifyListeners();
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
      await _hiveService.saveLocation(_location!);
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
      _nextPrayer = null;
      _nextPrayerCountdown = Duration.zero;
      return;
    }

    _todayPrayers = _prayerService.getDisplayTimesForDate(
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
    if (_location == null) {
      await _notificationService.schedulePrayerNotifications(
        enabled: false,
        soundMode: _settings.notificationSoundMode,
        upcomingPrayers: const <PrayerInfo>[],
      );
      return;
    }

    final upcomingPrayers = _prayerService.getUpcomingPrayers(
      location: _location!,
      calculationMethod: _settings.calculationMethod,
      numberOfDays: AppConstants.notificationHorizonDays,
    );

    await _notificationService.schedulePrayerNotifications(
      enabled: _settings.notificationsEnabled,
      soundMode: _settings.notificationSoundMode,
      upcomingPrayers: upcomingPrayers,
    );
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
    _tasbihCount = _hiveService.loadTasbihCount();
    _prayerTracker = _hiveService.loadPrayerTracker();
    _quranBookmarks = _hiveService.loadQuranBookmarks();
    _quranLastRead = _hiveService.loadQuranLastRead();
    _quranReaderPreferences = _hiveService.loadQuranReaderPreferences();
    _azkarTracker = _hiveService.loadAzkarTracker();
    _dailyContent = await _dailyContentService.getContentForDate(
      DateTime.now(),
    );
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
