import 'dart:convert';

import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  const AppLocalizations(this.locale, this._activeValues);

  final Locale locale;
  final Map<String, String> _activeValues;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('ms'),
    Locale('id'),
    Locale('ur'),
    Locale('hi'),
    Locale('tr'),
    Locale('bn'),
    Locale('fa'),
    Locale('fr'),
    Locale('de'),
    Locale('es'),
    Locale('ru'),
    Locale('it'),
    Locale('pt'),
    Locale('nl'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('az'),
    Locale('bs'),
    Locale('cs'),
    Locale('pl'),
    Locale('ro'),
    Locale('sv'),
    Locale('sq'),
    Locale('uz'),
    Locale('tt'),
    Locale('ug'),
    Locale('am'),
    Locale('ba'),
    Locale('ber'),
    Locale('bg'),
    Locale('ce'),
    Locale('dv'),
    Locale('ha'),
    Locale('ku'),
    Locale('ml'),
    Locale('my'),
    Locale('no'),
    Locale('ps'),
    Locale('sd'),
    Locale('si'),
    Locale('so'),
    Locale('sw'),
    Locale('ta'),
    Locale('tg'),
    Locale('th'),
  ];

  static AppLocalizations of(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (localization == null) {
      return AppLocalizations(
        const Locale('en'),
        _localizedValues['en'] ?? <String, String>{},
      );
    }
    return localization;
  }

  String tr(String key, [Map<String, String> params = const {}]) {
    var value = _activeValues[key] ?? key;
    params.forEach((paramKey, paramValue) {
      value = value.replaceAll('{$paramKey}', paramValue);
    });
    return value;
  }

  String prayerName(String prayerName) {
    final key = switch (prayerName.toLowerCase()) {
      'imsak' => 'prayerImsak',
      'fajr' => 'prayerFajr',
      'sunrise' => 'prayerSunrise',
      'dhuhr' => 'prayerDhuhr',
      'asr' => 'prayerAsr',
      'maghrib' => 'prayerMaghrib',
      'isha' => 'prayerIsha',
      'qiyam' => 'prayerQiyam',
      'midnight' => 'prayerMidnight',
      _ => '',
    };
    if (key.isEmpty) return prayerName;
    return tr(key);
  }

  String calculationMethodLabel(CalculationMethodOption method) {
    final key = switch (method) {
      CalculationMethodOption.muslimWorldLeague =>
        'calcMethodMuslimWorldLeague',
      CalculationMethodOption.egyptian => 'calcMethodEgyptian',
      CalculationMethodOption.karachi => 'calcMethodKarachi',
      CalculationMethodOption.ummAlQura => 'calcMethodUmmAlQura',
      CalculationMethodOption.dubai => 'calcMethodDubai',
      CalculationMethodOption.moonSightingCommittee => 'calcMethodMoonSighting',
      CalculationMethodOption.northAmerica => 'calcMethodNorthAmerica',
      CalculationMethodOption.kuwait => 'calcMethodKuwait',
      CalculationMethodOption.qatar => 'calcMethodQatar',
      CalculationMethodOption.singapore => 'calcMethodSingapore',
      CalculationMethodOption.turkey => 'calcMethodTurkey',
      CalculationMethodOption.tehran => 'calcMethodTehran',
    };
    return tr(key);
  }

  String notificationSoundLabel(NotificationSoundMode mode) {
    final key = switch (mode) {
      NotificationSoundMode.notificationOnly => 'notificationOnly',
      NotificationSoundMode.azanSound => 'azanSound',
    };
    return tr(key);
  }

  String themeModeLabel(ThemeModeOption option) {
    final key = switch (option) {
      ThemeModeOption.system => 'themeModeSystem',
      ThemeModeOption.light => 'themeModeLight',
      ThemeModeOption.dark => 'themeModeDark',
    };
    return tr(key);
  }

  String themeStyleLabel(ThemeStyleOption option) {
    final key = switch (option) {
      ThemeStyleOption.emerald => 'themeStyleEmerald',
      ThemeStyleOption.midnightDark => 'themeStyleMidnightDark',
      ThemeStyleOption.ocean => 'themeStyleOcean',
      ThemeStyleOption.sunset => 'themeStyleSunset',
      ThemeStyleOption.glass => 'themeStyleGlass',
      ThemeStyleOption.softUi => 'themeStyleSoftUi',
    };
    return tr(key);
  }
}

class _AssetLocalizationService {
  static final Map<String, Map<String, String>> _memoryCache =
      <String, Map<String, String>>{};

  static Future<Map<String, String>> load(String languageCode) async {
    if (_memoryCache[languageCode] != null) {
      return _memoryCache[languageCode]!;
    }
    try {
      final raw = await rootBundle.loadString(
        'assets/data/app_ui_locales/$languageCode.json',
      );
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        _memoryCache[languageCode] = <String, String>{};
        return _memoryCache[languageCode]!;
      }
      final parsed = decoded.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      _memoryCache[languageCode] = parsed;
      return parsed;
    } catch (_) {
      _memoryCache[languageCode] = <String, String>{};
      return _memoryCache[languageCode]!;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final englishValues = _localizedValues['en'] ?? <String, String>{};
    final staticValues =
        _localizedValues[locale.languageCode] ?? <String, String>{};
    final assetValues = await _AssetLocalizationService.load(
      locale.languageCode,
    );
    return AppLocalizations(locale, <String, String>{
      ...englishValues,
      ...staticValues,
      ...assetValues,
    });
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const Map<String, Map<String, String>>
_localizedValues = <String, Map<String, String>>{
  'en': <String, String>{
    'titlePrayerTimes': 'Prayer Times',
    'titleQuran': 'Quran',
    'titleTasbih': 'Tasbih',
    'titleQibla': 'Qibla',
    'titleSettings': 'Settings',
    'navHome': 'Home',
    'navQuran': 'Quran',
    'navTasbih': 'Tasbih',
    'navQibla': 'Qibla',
    'navSettings': 'Settings',
    'nextPrayer': 'Next Prayer',
    'unavailable': 'Unavailable',
    'startsIn': 'Starts in {duration}',
    'prayerTimes': 'Prayer Times',
    'copyTodaySchedule': 'Copy today schedule',
    'prayerDisplayFilter': 'Prayer display',
    'prayerDisplayFilterSub': 'Choose which prayer times to show',
    'save': 'Save',
    'mandatoryPrayersRequired':
        'At least one mandatory prayer must remain selected.',
    'scheduleCopied': 'Schedule copied',
    'obligatoryPrayer': 'Obligatory prayer',
    'additionalPrayer': 'Additional',
    'locationUnavailableHint':
        'Location not available yet. Open Settings to set location manually or fetch GPS.',
    'quickTracker': 'Tracker',
    'quickMosques': 'Mosques',
    'quickAzkar': 'Azkar',
    'dailyHadith': 'Daily Hadith',
    'dailyAyah': 'Daily Ayah',
    'dailyQuranAyahsTitle': 'Daily Quran Ayahs',
    'dailyQuranAyahsSubtitle':
        '3 ayahs for today with transliteration and translation',
    'hijriDate': 'Hijri Date',
    'ramadanStarted': 'Ramadan has started',
    'daysUntilRamadan': '{days} day(s) until Ramadan',
    'upcomingIslamicEvents': 'Upcoming Islamic Events in 6 Months',
    'upcomingEvens': 'Upcoming Evens',
    'filterEvents': 'Filter Events',
    'eventTypes': 'Event Types',
    'selectAtLeastOneEventType': 'Select at least one event type.',
    'daysShort': 'days',
    'apply': 'Apply',
    'cancel': 'Cancel',
    'ramadanLabel': 'Ramadan',
    'eidAlFitrLabel': 'Eid al-Fitr',
    'eidAlAdhaLabel': 'Eid al-Adha',
    'islamicNewYearLabel': 'Islamic New Year',
    'ashuraLabel': 'Ashura',
    'mawlidLabel': "Prophet's Birthday",
    'israMirajLabel': "Isra and Mi'raj",
    'midShabanLabel': "Mid-Sha'ban",
    'dayOfArafahLabel': 'Day of Arafah',
    'tashreeqDaysLabel': 'Days of Tashreeq',
    'jumuahLabel': "Jumu'ah",
    'eventInDays': '{days} day(s)',
    'tasbihCounter': 'Tasbih Counter',
    'tasbihSubtitle':
        'Tap the dhikr button to count. Your progress is saved automatically.',
    'currentCount': 'Current Count',
    'tap': 'Tap',
    'resetCounter': 'Reset Counter',
    'dailyAzkar': 'Daily Azkar',
    'unableLoadAzkarData': 'Unable to load azkar data.',
    'morningEveningRemembrance': 'Morning & Evening Remembrance',
    'morning': 'Morning',
    'evening': 'Evening',
    'progress': 'Progress',
    'completedToday': '{percent}% completed today',
    'countProgress': 'Count: {current} / {total}',
    'count': 'Count',
    'done': 'Done',
    'resetToday': 'Reset Today',
    'qiblaCompass': 'Qibla Compass',
    'qiblaInstruction': 'Point your phone flat and follow the green arrow',
    'loadingQiblaCompass': 'Loading Qibla compass...',
    'unableCheckQibla': 'Unable to check Qibla requirements right now.',
    'retry': 'Retry',
    'enableLocationServiceQibla':
        'Please enable location service for Qibla compass.',
    'openLocationSettings': 'Open Location Settings',
    'locationPermissionRequiredQibla':
        'Location permission is required to calculate Qibla direction.',
    'openAppSettings': 'Open App Settings',
    'compassUnavailable':
        'Compass data is unavailable. Move your phone in a figure-8 and try again.',
    'offsetDegrees': 'Offset: {offset} deg',
    'unstableDirectionTip':
        'Tip: If direction looks unstable, move your phone in a figure-8.',
    'location': 'Location',
    'locationSub': 'Use GPS or set coordinates manually',
    'citySearchLabel': 'Search City (Offline)',
    'citySearchHint': 'Type city name, e.g. Kuala Lumpur',
    'citySearchEmpty': 'No matching cities found.',
    'noSavedLocation': 'No saved location',
    'useCurrentLocation': 'Use Current Location',
    'latitude': 'Latitude',
    'longitude': 'Longitude',
    'cityNameOptional': 'City name (optional)',
    'leaveBlankAutoDetect': 'Leave blank to auto-detect',
    'saveManualLocation': 'Save Manual Location',
    'locationUpdatedFromGps': 'Location updated from GPS.',
    'manualLocationSaved': 'Manual location saved.',
    'notifications': 'Notifications',
    'notificationsSub': 'Control reminders and sound style',
    'enablePrayerNotifications': 'Enable prayer notifications',
    'notificationOnly': 'Notification only',
    'azanSound': 'Azan sound',
    'azanModeRequiresFile':
        'Azan mode requires android/app/src/main/res/raw/azan.mp3.',
    'prayerCalculation': 'Prayer Calculation',
    'prayerCalculationSub': 'Choose your preferred method',
    'calculationMethod': 'Calculation method',
    'appearance': 'Appearance',
    'appearanceSub': 'Theme mode and visual style',
    'themeMode': 'Theme mode',
    'themeStyle': 'Theme style',
    'language': 'Language',
    'languageSub': 'Choose app and Quran translation language',
    'appLanguage': 'App language',
    'dataBackup': 'Data & Backup',
    'dataBackupSub': 'Export or restore your local app data',
    'export': 'Export',
    'restore': 'Restore',
    'backupExported': 'Backup exported successfully.',
    'backupRestored': 'Backup restored successfully.',
    'saveBackupFile': 'Save backup file',
    'selectBackupFile': 'Select backup file',
    'helpQa': 'Q&A',
    'helpQaSub': 'Quick answers for common app questions',
    'support': 'Support',
    'supportSub': 'Get help or contact the developer',
    'helpFaqButton': 'Help & FAQ',
    'helpFaqButtonSub': 'Browse common questions and answers',
    'contactDeveloperButton': 'Contact Developer',
    'contactDeveloperButtonSub': 'Send suggestions or report issues',
    'faqQiblaQuestion': 'Qibla direction looks unstable. What should I do?',
    'faqQiblaAnswer':
        'Keep the phone flat and move it in a figure-8 to calibrate the compass sensors.',
    'faqLocationQuestion': 'Why are prayer times incorrect?',
    'faqLocationAnswer':
        'Update GPS location in Settings and verify your calculation method is correct for your region.',
    'faqLanguageQuestion': 'Why did only Quran language change, not app UI?',
    'faqLanguageAnswer':
        'Quran translation language and app UI language are separate. Change app UI language in Settings > Language > App language.',
    'faqReadingTrackerQuestion':
        'How is Quran reading time calculated accurately?',
    'faqReadingTrackerAnswer':
        'Reading time counts only while you interact with the Quran screen (scroll/touch). Idle time is paused automatically after a short delay.',
    'faqQuranReaderQuestion':
        'How can I show or hide transliteration and translation?',
    'faqQuranReaderAnswer':
        'Open any surah, tap Reader Settings, then enable or disable transliteration and translation as needed.',
    'faqCitySearchQuestion': 'Can I search cities without internet?',
    'faqCitySearchAnswer':
        'Yes. City search is fully offline. Type a city name in Settings > Location and select from suggestions.',
    'faqPrayerNotificationQuestion':
        'Prayer notification did not ring with Azan sound. Why?',
    'faqPrayerNotificationAnswer':
        'Enable notifications in Settings and choose Azan sound mode. On Android, make sure notification permission is allowed.',
    'faqThemeQuestion': 'I changed theme style but see little difference.',
    'faqThemeAnswer':
        'Some pages use subtle style changes. Try switching both Theme mode and Theme style, then reopen the page to see full effect.',
    'faqBackupQuestion': 'How can I move my data to another phone?',
    'faqBackupAnswer':
        'Use Export to create a backup file, then use Restore on the new phone.',
    'faqAudioQuestion': 'Quran audio is not playing.',
    'faqAudioAnswer':
        'Check internet for first-time loading. After first play, audio is cached for offline playback.',
    'developerFeedback': 'Message Developer',
    'developerFeedbackSub': 'Send suggestions to improve this app',
    'developerFeedbackHint':
        'Share ideas, report bugs, or request new features directly.',
    'sendMessage': 'Send Message',
    'sendSuggestionTitle': 'Send Suggestion',
    'sendSuggestionHint': 'Write your suggestion here...',
    'sendEmailInBackground': 'Send email in background',
    'sendViaEmail': 'Send via Email',
    'sendingEmailInBackground': 'Opening email app in background...',
    'messageSavedLocally': 'Message saved. You can send it later.',
    'suggestionEmpty': 'Please write your message first.',
    'openEmailFailed': 'Could not open email app on this device.',
    'suggestionSentPrompt':
        'Email app opened. Send the message there to reach the developer.',
    'suggestionEmailSubject': 'Azan App Suggestion',
    'quranSubtitle': '114 Surahs - Arabic + translation',
    'quranMainOptions': 'Main Options',
    'quranSecondaryOptions': 'More Options',
    'quranWithTranslation': 'Quran with Translation',
    'quranArabicOnly': 'Quran (Arabic Only)',
    'quranArabicOnlySubtitle': 'Arabic text only with focused reading mode',
    'quranAudioSubtitle': 'Open any surah and start recitation with ayah sync',
    'quranDailyAyahSubtitle': 'A new ayah every day for reflection',
    'quranSearchSubtitle': 'Search by surah name, ayah number, or keyword',
    'quranReadingSettingsSubtitle':
        'Adjust font size and transliteration/translation display',
    'searchSurahAyah': 'Search surah or ayah (Arabic/translation)',
    'failedLoadQuran': 'Failed to load Quran data. Please restart the app.',
    'resumeReading': 'Resume Reading',
    'startReading': 'Start Reading',
    'lastReadPosition': 'Last read',
    'quranReadingToday': 'Reading today',
    'minutesShort': '{count} min',
    'lessThanMinute': '<1 min',
    'bookmarks': 'Bookmarks',
    'savedCount': '{count} saved',
    'ayahMatches': 'Ayah Matches ({count})',
    'openAyah': 'Open Ayah',
    'surahResults': 'Surah Results',
    'noResults': 'No results found. Try another keyword.',
    'ayah': 'Ayah',
    'previous': 'Previous',
    'next': 'Next',
    'readerSettings': 'Reader Settings',
    'showTransliteration': 'Show transliteration',
    'hideTransliteration': 'Hide transliteration',
    'showTranslation': 'Show translation',
    'hideTranslation': 'Hide translation',
    'arabicFontSize': 'Arabic font size: {size}',
    'translationFontSize': 'Translation font size: {size}',
    'bookmarkAyah': 'Bookmark ayah',
    'copyAyah': 'Copy ayah',
    'ayahCopied': 'Ayah copied',
    'unablePlayAudio': 'Unable to play audio now. Please check internet.',
    'openFullPlayer': 'Open full player',
    'play': 'Play',
    'pause': 'Pause',
    'quranPlayer': 'Quran Player',
    'prayerTracker': 'Prayer Tracker',
    'today': 'Today',
    'last7Days': 'Last 7 Days',
    'percentCompleted': '{percent}% completed',
    'markTodaysPrayers': "Mark Today's Prayers",
    'nearbyMosques': 'Nearby Mosques',
    'setLocationFirst':
        'Set your location first in Settings to use Mosque Finder.',
    'failedLoadMosques': 'Failed to load nearby mosques. Please try again.',
    'yourLocation': 'Your location',
    'mosquesFound': '{count} mosque(s) found within ~3 km',
    'noMosqueFound': 'No nearby mosque found in selected radius.',
    'distance': 'Distance: {distance}',
    'details': 'Details',
    'open': 'Open',
    'close': 'Close',
    'navigate': 'Navigate',
    'calcMethodMuslimWorldLeague': 'Muslim World League',
    'calcMethodEgyptian': 'Egyptian',
    'calcMethodKarachi': 'Karachi',
    'calcMethodUmmAlQura': 'Umm Al-Qura',
    'calcMethodDubai': 'Dubai',
    'calcMethodMoonSighting': 'Moon Sighting Committee',
    'calcMethodNorthAmerica': 'North America (ISNA)',
    'calcMethodKuwait': 'Kuwait',
    'calcMethodQatar': 'Qatar',
    'calcMethodSingapore': 'Singapore',
    'calcMethodTurkey': 'Turkey',
    'calcMethodTehran': 'Tehran',
    'themeModeSystem': 'System',
    'themeModeLight': 'Light',
    'themeModeDark': 'Dark',
    'themeStyleEmerald': 'Emerald',
    'themeStyleMidnightDark': 'Midnight Dark',
    'themeStyleOcean': 'Ocean',
    'themeStyleSunset': 'Sunset',
    'themeStyleGlass': 'Glass',
    'themeStyleSoftUi': 'Soft UI',
    'prayerFajr': 'Fajr',
    'prayerImsak': 'Imsak',
    'prayerSunrise': 'Sunrise',
    'prayerDhuhr': 'Dhuhr',
    'prayerAsr': 'Asr',
    'prayerMaghrib': 'Maghrib',
    'prayerIsha': 'Isha',
    'prayerQiyam': 'Qiyam',
    'prayerMidnight': 'Midnight',
  },
  'ar': <String, String>{
    'titlePrayerTimes': 'مواقيت الصلاة',
    'titleQuran': 'القرآن',
    'titleTasbih': 'التسبيح',
    'titleQibla': 'القبلة',
    'titleSettings': 'الإعدادات',
    'navHome': 'الرئيسية',
    'navQuran': 'القرآن',
    'navTasbih': 'تسبيح',
    'navQibla': 'القبلة',
    'navSettings': 'الإعدادات',
    'nextPrayer': 'الصلاة التالية',
    'startsIn': 'تبدأ بعد {duration}',
    'prayerTimes': 'مواقيت الصلاة',
    'copyTodaySchedule': 'نسخ جدول اليوم',
    'scheduleCopied': 'تم نسخ الجدول',
    'obligatoryPrayer': 'صلاة مفروضة',
    'additionalPrayer': 'إضافية',
    'locationUnavailableHint':
        'الموقع غير متاح بعد. افتح الإعدادات لتحديد الموقع يدويًا أو عبر GPS.',
    'quickTracker': 'المتابعة',
    'quickMosques': 'المساجد',
    'quickAzkar': 'الأذكار',
    'dailyHadith': 'حديث اليوم',
    'dailyAyah': 'آية اليوم',
    'hijriDate': 'التاريخ الهجري',
    'ramadanStarted': 'بدأ رمضان',
    'daysUntilRamadan': 'متبقي {days} يوم حتى رمضان',
    'tasbihCounter': 'عداد التسبيح',
    'tasbihSubtitle': 'اضغط زر الذكر للعد. يتم حفظ تقدمك تلقائيًا.',
    'currentCount': 'العدد الحالي',
    'tap': 'اضغط',
    'resetCounter': 'إعادة التصفير',
    'dailyAzkar': 'أذكار يومية',
    'morningEveningRemembrance': 'أذكار الصباح والمساء',
    'morning': 'الصباح',
    'evening': 'المساء',
    'progress': 'التقدم',
    'completedToday': 'اكتمل {percent}% اليوم',
    'count': 'عد',
    'done': 'تم',
    'resetToday': 'إعادة اليوم',
    'qiblaCompass': 'بوصلة القبلة',
    'qiblaInstruction': 'ضع الهاتف بشكل مسطح واتبع السهم الأخضر',
    'loadingQiblaCompass': 'جارٍ تحميل بوصلة القبلة...',
    'unableCheckQibla': 'تعذر التحقق من متطلبات القبلة الآن.',
    'retry': 'إعادة المحاولة',
    'enableLocationServiceQibla': 'يرجى تفعيل خدمة الموقع لبوصلة القبلة.',
    'openLocationSettings': 'فتح إعدادات الموقع',
    'locationPermissionRequiredQibla': 'مطلوب إذن الموقع لحساب اتجاه القبلة.',
    'openAppSettings': 'فتح إعدادات التطبيق',
    'compassUnavailable':
        'بيانات البوصلة غير متاحة. حرّك هاتفك بشكل رقم 8 ثم أعد المحاولة.',
    'offsetDegrees': 'الانحراف: {offset} درجة',
    'unstableDirectionTip':
        'نصيحة: إذا كان الاتجاه غير ثابت فحرّك الهاتف بشكل رقم 8.',
    'location': 'الموقع',
    'locationSub': 'استخدم GPS أو أدخل الإحداثيات يدويًا',
    'noSavedLocation': 'لا يوجد موقع محفوظ',
    'useCurrentLocation': 'استخدام الموقع الحالي',
    'latitude': 'خط العرض',
    'longitude': 'خط الطول',
    'cityNameOptional': 'اسم المدينة (اختياري)',
    'leaveBlankAutoDetect': 'اتركه فارغًا للاكتشاف التلقائي',
    'saveManualLocation': 'حفظ الموقع اليدوي',
    'locationUpdatedFromGps': 'تم تحديث الموقع من GPS.',
    'manualLocationSaved': 'تم حفظ الموقع اليدوي.',
    'notifications': 'الإشعارات',
    'notificationsSub': 'التحكم بالتنبيهات ونوع الصوت',
    'enablePrayerNotifications': 'تفعيل إشعارات الصلاة',
    'notificationOnly': 'إشعار فقط',
    'azanSound': 'صوت الأذان',
    'prayerCalculation': 'حساب الصلاة',
    'prayerCalculationSub': 'اختر طريقة الحساب المفضلة',
    'calculationMethod': 'طريقة الحساب',
    'appearance': 'المظهر',
    'appearanceSub': 'وضع السمة والنمط',
    'themeMode': 'وضع السمة',
    'themeStyle': 'نمط السمة',
    'language': 'اللغة',
    'languageSub': 'اختر لغة التطبيق وترجمة القرآن',
    'appLanguage': 'لغة التطبيق',
    'dataBackup': 'البيانات والنسخ الاحتياطي',
    'dataBackupSub': 'تصدير أو استعادة بيانات التطبيق المحلية',
    'export': 'تصدير',
    'restore': 'استعادة',
    'backupExported': 'تم تصدير النسخة الاحتياطية بنجاح.',
    'backupRestored': 'تمت استعادة النسخة الاحتياطية بنجاح.',
    'saveBackupFile': 'حفظ ملف النسخة الاحتياطية',
    'selectBackupFile': 'اختر ملف النسخة الاحتياطية',
    'quranSubtitle': '114 سورة - عربي + ترجمة',
    'searchSurahAyah': 'ابحث عن سورة أو آية (عربي/ترجمة)',
    'failedLoadQuran': 'تعذر تحميل بيانات القرآن. يرجى إعادة تشغيل التطبيق.',
    'resumeReading': 'متابعة القراءة',
    'bookmarks': 'الإشارات',
    'savedCount': 'تم حفظ {count}',
    'ayahMatches': 'نتائج الآيات ({count})',
    'openAyah': 'فتح الآية',
    'surahResults': 'نتائج السور',
    'noResults': 'لا توجد نتائج. جرّب كلمة أخرى.',
    'ayah': 'آية',
    'previous': 'السابق',
    'next': 'التالي',
    'readerSettings': 'إعدادات القراءة',
    'showTranslation': 'إظهار الترجمة',
    'hideTranslation': 'إخفاء الترجمة',
    'arabicFontSize': 'حجم خط العربية: {size}',
    'translationFontSize': 'حجم خط الترجمة: {size}',
    'bookmarkAyah': 'حفظ إشارة للآية',
    'copyAyah': 'نسخ الآية',
    'ayahCopied': 'تم نسخ الآية',
    'unablePlayAudio': 'تعذر تشغيل الصوت الآن. تحقق من الإنترنت.',
    'openFullPlayer': 'فتح المشغل الكامل',
    'play': 'تشغيل',
    'pause': 'إيقاف',
    'quranPlayer': 'مشغل القرآن',
    'prayerTracker': 'متابعة الصلوات',
    'today': 'اليوم',
    'last7Days': 'آخر 7 أيام',
    'percentCompleted': 'اكتمل {percent}%',
    'markTodaysPrayers': 'تحديد صلوات اليوم',
    'nearbyMosques': 'المساجد القريبة',
    'setLocationFirst':
        'حدد موقعك أولاً من الإعدادات لاستخدام الباحث عن المساجد.',
    'failedLoadMosques': 'تعذر تحميل المساجد القريبة. حاول مرة أخرى.',
    'yourLocation': 'موقعك',
    'mosquesFound': 'تم العثور على {count} مسجد ضمن ~3 كم',
    'noMosqueFound': 'لم يتم العثور على مساجد قريبة ضمن النطاق المحدد.',
    'distance': 'المسافة: {distance}',
    'details': 'التفاصيل',
    'open': 'فتح',
    'close': 'إغلاق',
    'navigate': 'تنقل',
    'prayerFajr': 'الفجر',
    'prayerSunrise': 'الشروق',
    'prayerDhuhr': 'الظهر',
    'prayerAsr': 'العصر',
    'prayerMaghrib': 'المغرب',
    'prayerIsha': 'العشاء',
  },
  'ms': <String, String>{
    'titlePrayerTimes': 'Waktu Solat',
    'titleQuran': 'Al-Quran',
    'titleTasbih': 'Tasbih',
    'titleQibla': 'Kiblat',
    'titleSettings': 'Tetapan',
    'navHome': 'Utama',
    'navQuran': 'Quran',
    'navTasbih': 'Tasbih',
    'navQibla': 'Kiblat',
    'navSettings': 'Tetapan',
    'nextPrayer': 'Solat Seterusnya',
    'startsIn': 'Bermula dalam {duration}',
    'prayerTimes': 'Waktu Solat',
    'copyTodaySchedule': 'Salin jadual hari ini',
    'scheduleCopied': 'Jadual disalin',
    'language': 'Bahasa',
    'languageSub': 'Pilih bahasa aplikasi dan terjemahan Quran',
    'appLanguage': 'Bahasa aplikasi',
    'quranSubtitle': '114 Surah - Arab + terjemahan',
    'searchSurahAyah': 'Cari surah atau ayat (Arab/terjemahan)',
    'readerSettings': 'Tetapan Pembaca',
    'showTranslation': 'Tunjuk terjemahan',
    'hideTranslation': 'Sembunyi terjemahan',
    'prayerFajr': 'Subuh',
    'prayerSunrise': 'Syuruk',
    'prayerDhuhr': 'Zohor',
    'prayerAsr': 'Asar',
    'prayerMaghrib': 'Maghrib',
    'prayerIsha': 'Isyak',
  },
  'id': <String, String>{
    'titlePrayerTimes': 'Waktu Sholat',
    'titleQuran': 'Quran',
    'titleTasbih': 'Tasbih',
    'titleQibla': 'Kiblat',
    'titleSettings': 'Pengaturan',
    'navHome': 'Beranda',
    'navQuran': 'Quran',
    'navTasbih': 'Tasbih',
    'navQibla': 'Kiblat',
    'navSettings': 'Pengaturan',
    'nextPrayer': 'Sholat Berikutnya',
    'startsIn': 'Mulai dalam {duration}',
    'prayerTimes': 'Waktu Sholat',
    'copyTodaySchedule': 'Salin jadwal hari ini',
    'scheduleCopied': 'Jadwal disalin',
    'language': 'Bahasa',
    'languageSub': 'Pilih bahasa aplikasi dan terjemahan Quran',
    'appLanguage': 'Bahasa aplikasi',
    'quranSubtitle': '114 Surah - Arab + terjemahan',
    'searchSurahAyah': 'Cari surah atau ayat (Arab/terjemahan)',
    'readerSettings': 'Pengaturan Pembaca',
    'showTranslation': 'Tampilkan terjemahan',
    'hideTranslation': 'Sembunyikan terjemahan',
    'prayerFajr': 'Subuh',
    'prayerSunrise': 'Terbit',
    'prayerDhuhr': 'Dzuhur',
    'prayerAsr': 'Ashar',
    'prayerMaghrib': 'Maghrib',
    'prayerIsha': 'Isya',
  },
  'ur': <String, String>{
    'titlePrayerTimes': 'نماز کے اوقات',
    'titleQuran': 'قرآن',
    'titleTasbih': 'تسبیح',
    'titleQibla': 'قبلہ',
    'titleSettings': 'ترتیبات',
    'navHome': 'ہوم',
    'navQuran': 'قرآن',
    'navTasbih': 'تسبیح',
    'navQibla': 'قبلہ',
    'navSettings': 'ترتیبات',
    'nextPrayer': 'اگلی نماز',
    'startsIn': '{duration} میں شروع',
    'prayerTimes': 'نماز کے اوقات',
    'copyTodaySchedule': 'آج کا شیڈول کاپی کریں',
    'scheduleCopied': 'شیڈول کاپی ہو گیا',
    'language': 'زبان',
    'languageSub': 'ایپ اور قرآن ترجمہ کی زبان منتخب کریں',
    'appLanguage': 'ایپ زبان',
    'quranSubtitle': '114 سورتیں - عربی + ترجمہ',
    'searchSurahAyah': 'سورہ یا آیت تلاش کریں (عربی/ترجمہ)',
    'readerSettings': 'ریڈر سیٹنگز',
    'showTranslation': 'ترجمہ دکھائیں',
    'hideTranslation': 'ترجمہ چھپائیں',
    'prayerFajr': 'فجر',
    'prayerSunrise': 'طلوع',
    'prayerDhuhr': 'ظہر',
    'prayerAsr': 'عصر',
    'prayerMaghrib': 'مغرب',
    'prayerIsha': 'عشاء',
  },
  'hi': <String, String>{
    'titlePrayerTimes': 'नमाज़ समय',
    'titleQuran': 'कुरआन',
    'titleTasbih': 'तस्बीह',
    'titleQibla': 'क़िबला',
    'titleSettings': 'सेटिंग्स',
    'navHome': 'होम',
    'navQuran': 'कुरआन',
    'navTasbih': 'तस्बीह',
    'navQibla': 'क़िबला',
    'navSettings': 'सेटिंग्स',
    'nextPrayer': 'अगली नमाज़',
    'startsIn': '{duration} में शुरू',
    'prayerTimes': 'नमाज़ समय',
    'copyTodaySchedule': 'आज का शेड्यूल कॉपी करें',
    'scheduleCopied': 'शेड्यूल कॉपी हो गया',
    'language': 'भाषा',
    'languageSub': 'ऐप और कुरआन अनुवाद भाषा चुनें',
    'appLanguage': 'ऐप भाषा',
    'quranSubtitle': '114 सूरह - अरबी + अनुवाद',
    'searchSurahAyah': 'सूरह या आयत खोजें (अरबी/अनुवाद)',
    'readerSettings': 'रीडर सेटिंग्स',
    'showTranslation': 'अनुवाद दिखाएं',
    'hideTranslation': 'अनुवाद छुपाएं',
    'prayerFajr': 'फ़ज्र',
    'prayerSunrise': 'सूर्योदय',
    'prayerDhuhr': 'ज़ुहर',
    'prayerAsr': 'असर',
    'prayerMaghrib': 'मगरिब',
    'prayerIsha': 'इशा',
  },
  'tr': <String, String>{
    'titlePrayerTimes': 'Namaz Vakitleri',
    'titleQuran': 'Kuran',
    'titleTasbih': 'Tesbih',
    'titleQibla': 'Kıble',
    'titleSettings': 'Ayarlar',
    'navHome': 'Ana Sayfa',
    'navQuran': 'Kuran',
    'navTasbih': 'Tesbih',
    'navQibla': 'Kıble',
    'navSettings': 'Ayarlar',
    'nextPrayer': 'Sonraki Namaz',
    'startsIn': '{duration} sonra',
    'prayerTimes': 'Namaz Vakitleri',
    'copyTodaySchedule': 'Bugünkü programı kopyala',
    'scheduleCopied': 'Program kopyalandı',
    'language': 'Dil',
    'languageSub': 'Uygulama ve Kuran çeviri dilini seçin',
    'appLanguage': 'Uygulama dili',
    'quranSubtitle': '114 Sure - Arapça + çeviri',
    'searchSurahAyah': 'Sure veya ayet ara (Arapça/çeviri)',
    'readerSettings': 'Okuyucu Ayarları',
    'showTranslation': 'Çeviriyi göster',
    'hideTranslation': 'Çeviriyi gizle',
    'prayerFajr': 'İmsak',
    'prayerSunrise': 'Güneş',
    'prayerDhuhr': 'Öğle',
    'prayerAsr': 'İkindi',
    'prayerMaghrib': 'Akşam',
    'prayerIsha': 'Yatsı',
  },
};
