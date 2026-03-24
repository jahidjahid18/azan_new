import 'dart:async';
import 'dart:io';

import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/models/app_settings.dart';
import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/services/hive_service.dart';
import 'package:azan_app/core/services/home_widget_service.dart';
import 'package:azan_app/core/services/location_service.dart';
import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_service.dart';
import 'package:azan_app/features/azkar/data/models/saved_azkar_item.dart';
import 'package:azan_app/features/daily/data/daily_content_service.dart';
import 'package:azan_app/features/daily/data/models/daily_content_item.dart';
import 'package:azan_app/features/daily/data/models/saved_daily_item.dart';
import 'package:azan_app/features/quran/data/models/quran_bookmark.dart';
import 'package:azan_app/features/quran/data/models/quran_reader_preferences.dart';
import 'package:azan_app/features/quran/data/models/quran_read_position.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/foundation.dart';

class AppController extends ChangeNotifier {
  AppController({
    required HiveService hiveService,
    required LocationService locationService,
    required PrayerService prayerService,
    required NotificationService notificationService,
    required DailyContentService dailyContentService,
    required HomeWidgetService homeWidgetService,
  }) : _hiveService = hiveService,
       _locationService = locationService,
       _prayerService = prayerService,
       _notificationService = notificationService,
       _dailyContentService = dailyContentService,
       _homeWidgetService = homeWidgetService;

  final HiveService _hiveService;
  final LocationService _locationService;
  final PrayerService _prayerService;
  final NotificationService _notificationService;
  final DailyContentService _dailyContentService;
  final HomeWidgetService _homeWidgetService;

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
  Map<String, dynamic> _azkarTracker = <String, dynamic>{};
  List<SavedDailyItem> _dailyFavorites = <SavedDailyItem>[];
  List<SavedAzkarItem> _azkarFavorites = <SavedAzkarItem>[];
  QuranReaderPreferences _quranReaderPreferences =
      QuranReaderPreferences.defaults();

  String _lastWidgetSignature = '';

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
  List<QuranBookmark> get quranBookmarks => _quranBookmarks;
  QuranReadPosition? get quranLastRead => _quranLastRead;
  List<SavedDailyItem> get dailyFavorites => _dailyFavorites;
  List<SavedAzkarItem> get azkarFavorites => _azkarFavorites;
  QuranReaderPreferences get quranReaderPreferences => _quranReaderPreferences;

  Future<void> initialize() async {
    try {
      await _hiveService.init();
      await _notificationService.initialize();

      _settings = _hiveService.loadSettings();
      _location = _hiveService.loadLocation();
      _tasbihCount = _hiveService.loadTasbihCount();
      _prayerTracker = _hiveService.loadPrayerTracker();
      _quranBookmarks = _hiveService.loadQuranBookmarks();
      _quranLastRead = _hiveService.loadQuranLastRead();
      _azkarTracker = _hiveService.loadAzkarTracker();
      _dailyFavorites = _hiveService.loadDailyFavorites();
      _azkarFavorites = _hiveService.loadAzkarFavorites();
      _quranReaderPreferences = _hiveService.loadQuranReaderPreferences();

      if (_location == null) {
        await _setLocationFromGps(showErrorsAsStartupError: true);
      }

      _recalculatePrayers();
      _dailyContent = await _dailyContentService.getContentForDate(_now);
      await _refreshNotificationSchedule();
      await _syncHomeWidgetIfNeeded(force: true);
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
      await _syncHomeWidgetIfNeeded(force: true);
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
      await _syncHomeWidgetIfNeeded(force: true);
      _startTickerIfNeeded();
    });
  }

  Future<void> updateCalculationMethod(CalculationMethodOption method) async {
    _settings = _settings.copyWith(calculationMethod: method);
    await _hiveService.saveSettings(_settings);
    _recalculatePrayers();
    await _refreshNotificationSchedule();
    await _syncHomeWidgetIfNeeded(force: true);
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
        completionByDate: const <String, Map<String, bool>>{},
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
      completionByDate: _completionByDateForNotifications(),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final previousDate = DateTime(_now.year, _now.month, _now.day);
      final previousMinute = DateTime(
        _now.year,
        _now.month,
        _now.day,
        _now.hour,
        _now.minute,
      );

      _now = DateTime.now();
      _nextPrayerCountdown = _nextPrayer == null
          ? Duration.zero
          : _nextPrayer!.time.difference(_now);

      final currentDate = DateTime(_now.year, _now.month, _now.day);
      final currentMinute = DateTime(
        _now.year,
        _now.month,
        _now.day,
        _now.hour,
        _now.minute,
      );

      if (currentDate.isAfter(previousDate) ||
          _nextPrayerCountdown.isNegative) {
        _recalculatePrayers();
        if (currentDate.isAfter(previousDate)) {
          unawaited(_refreshDailyContent());
          unawaited(_refreshNotificationSchedule());
        }
        unawaited(_syncHomeWidgetIfNeeded(force: true));
      } else if (currentMinute.isAfter(previousMinute)) {
        unawaited(_syncHomeWidgetIfNeeded());
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
    await _refreshNotificationSchedule();
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

  double prayerCompletionPercentForDate(DateTime date) {
    final tracker = prayerTrackerForDate(date);
    final completedCount = tracker.values.where((value) => value).length;
    return completedCount / AppConstants.prayerOrder.length;
  }

  int currentPrayerStreakDays() {
    var streak = 0;
    for (var i = 0; i < 365; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final isFullDayComplete = prayerCompletionPercentForDate(date) >= 1;
      if (!isFullDayComplete) {
        break;
      }
      streak += 1;
    }
    return streak;
  }

  List<double> last30DaysCompletion() {
    final values = <double>[];
    for (var i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      values.add(prayerCompletionPercentForDate(date));
    }
    return values;
  }

  int completedPrayersToday() {
    final today = prayerTrackerForDate(DateTime.now());
    return today.values.where((value) => value).length;
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
    required String surahNameEnglish,
    required String surahNameArabic,
  }) async {
    final existingIndex = _quranBookmarks.indexWhere(
      (bookmark) =>
          bookmark.surahNumber == surahNumber &&
          bookmark.ayahNumber == ayahNumber,
    );

    if (existingIndex >= 0) {
      final updated = List<QuranBookmark>.from(_quranBookmarks)
        ..removeAt(existingIndex);
      _quranBookmarks = updated;
    } else {
      final updated = List<QuranBookmark>.from(_quranBookmarks)
        ..insert(
          0,
          QuranBookmark(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            surahNameEnglish: surahNameEnglish,
            surahNameArabic: surahNameArabic,
            updatedAt: DateTime.now(),
          ),
        );
      _quranBookmarks = updated;
    }

    await _hiveService.saveQuranBookmarks(_quranBookmarks);
    notifyListeners();
  }

  Future<void> setQuranLastRead({
    required int surahNumber,
    required int ayahNumber,
    required String surahNameEnglish,
    required String surahNameArabic,
  }) async {
    _quranLastRead = QuranReadPosition(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      surahNameEnglish: surahNameEnglish,
      surahNameArabic: surahNameArabic,
      updatedAt: DateTime.now(),
    );

    await _hiveService.saveQuranLastRead(_quranLastRead!);
    notifyListeners();
  }

  Map<String, int> azkarCountsForDateCategory(DateTime date, String category) {
    final key = _azkarTrackerKey(date, category);
    final raw = _azkarTracker[key];

    if (raw is! Map) {
      return <String, int>{};
    }

    return raw.map<String, int>((dynamic k, dynamic v) {
      final value = v is int ? v : int.tryParse(v.toString()) ?? 0;
      return MapEntry<String, int>(k.toString(), value);
    });
  }

  Future<void> incrementAzkarCount({
    required DateTime date,
    required String category,
    required String itemId,
    required int maxCount,
  }) async {
    final key = _azkarTrackerKey(date, category);
    final current = Map<String, int>.from(
      azkarCountsForDateCategory(date, category),
    );

    final existing = current[itemId] ?? 0;
    final next = existing < maxCount ? existing + 1 : maxCount;
    current[itemId] = next;

    _azkarTracker[key] = current;
    await _hiveService.saveAzkarTracker(_azkarTracker);
    notifyListeners();
  }

  Future<void> resetAzkarCategory({
    required DateTime date,
    required String category,
  }) async {
    final key = _azkarTrackerKey(date, category);
    _azkarTracker.remove(key);
    await _hiveService.saveAzkarTracker(_azkarTracker);
    notifyListeners();
  }

  bool isDailyFavorite(DailyContentItem item) {
    final id = '${item.type}:${item.title}:${item.reference}';
    return _dailyFavorites.any((favorite) => favorite.id == id);
  }

  Future<void> toggleDailyFavorite(DailyContentItem item) async {
    final candidate = SavedDailyItem.fromDailyContent(item);
    final index = _dailyFavorites.indexWhere(
      (favorite) => favorite.id == candidate.id,
    );

    if (index >= 0) {
      final updated = List<SavedDailyItem>.from(_dailyFavorites)
        ..removeAt(index);
      _dailyFavorites = updated;
    } else {
      final updated = List<SavedDailyItem>.from(_dailyFavorites)
        ..insert(0, candidate);
      _dailyFavorites = updated;
    }

    await _hiveService.saveDailyFavorites(_dailyFavorites);
    notifyListeners();
  }

  bool isAzkarFavorite(String id) {
    return _azkarFavorites.any((favorite) => favorite.id == id);
  }

  Future<void> toggleAzkarFavorite({
    required String id,
    required String category,
    required String text,
    required String source,
    required int repeat,
  }) async {
    final index = _azkarFavorites.indexWhere((favorite) => favorite.id == id);
    if (index >= 0) {
      final updated = List<SavedAzkarItem>.from(_azkarFavorites)
        ..removeAt(index);
      _azkarFavorites = updated;
    } else {
      final updated = List<SavedAzkarItem>.from(_azkarFavorites)
        ..insert(
          0,
          SavedAzkarItem(
            id: id,
            category: category,
            text: text,
            source: source,
            repeat: repeat,
            savedAt: DateTime.now(),
          ),
        );
      _azkarFavorites = updated;
    }

    await _hiveService.saveAzkarFavorites(_azkarFavorites);
    notifyListeners();
  }

  Future<void> updateQuranReaderPreferences({
    double? fontSize,
    double? lineHeight,
    bool? nightMode,
  }) async {
    _quranReaderPreferences = _quranReaderPreferences.copyWith(
      fontSize: fontSize,
      lineHeight: lineHeight,
      nightMode: nightMode,
    );
    await _hiveService.saveQuranReaderPreferences(_quranReaderPreferences);
    notifyListeners();
  }

  Future<void> _refreshDailyContent() async {
    _dailyContent = await _dailyContentService.getContentForDate(_now);
    notifyListeners();
  }

  Map<String, Map<String, bool>> _completionByDateForNotifications() {
    final typed = <String, Map<String, bool>>{};
    for (final entry in _prayerTracker.entries) {
      if (entry.value is! Map) continue;
      final rawMap = Map<String, dynamic>.from(entry.value as Map);
      typed[entry.key] = <String, bool>{
        for (final prayer in AppConstants.prayerOrder)
          prayer: rawMap[prayer] as bool? ?? false,
      };
    }
    return typed;
  }

  Future<void> _syncHomeWidgetIfNeeded({bool force = false}) async {
    if (kIsWeb || !Platform.isAndroid || _location == null) {
      return;
    }

    final minuteKey =
        '${_now.year}-${_now.month}-${_now.day} ${_now.hour}:${_now.minute}';
    final nextPrayerKey = _nextPrayer == null
        ? 'none'
        : '${_nextPrayer!.name}-${_nextPrayer!.time.toIso8601String()}';

    final signature = '${_location!.cityName}|$nextPrayerKey|$minuteKey';
    if (!force && signature == _lastWidgetSignature) {
      return;
    }

    _lastWidgetSignature = signature;

    try {
      await _homeWidgetService.updateNextPrayerWidget(
        cityName: _location!.cityName,
        nextPrayer: _nextPrayer,
        countdown: _nextPrayerCountdown,
      );
    } catch (_) {
      // Ignore widget update failures to keep app resilient.
    }
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }

  String _azkarTrackerKey(DateTime date, String category) {
    return '${_dateKey(date)}::$category';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
