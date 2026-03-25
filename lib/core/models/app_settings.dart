import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';

class AppSettings {
  const AppSettings({
    required this.calculationMethod,
    required this.notificationsEnabled,
    required this.notificationSoundMode,
    required this.themeMode,
    required this.themeStyle,
    required this.appLanguage,
  });

  final CalculationMethodOption calculationMethod;
  final bool notificationsEnabled;
  final NotificationSoundMode notificationSoundMode;
  final ThemeModeOption themeMode;
  final ThemeStyleOption themeStyle;
  final AppLanguage appLanguage;

  factory AppSettings.defaults() {
    return const AppSettings(
      calculationMethod: CalculationMethodOption.muslimWorldLeague,
      notificationsEnabled: true,
      notificationSoundMode: NotificationSoundMode.notificationOnly,
      themeMode: ThemeModeOption.system,
      themeStyle: ThemeStyleOption.muslimPro,
      appLanguage: AppLanguage.english,
    );
  }

  AppSettings copyWith({
    CalculationMethodOption? calculationMethod,
    bool? notificationsEnabled,
    NotificationSoundMode? notificationSoundMode,
    ThemeModeOption? themeMode,
    ThemeStyleOption? themeStyle,
    AppLanguage? appLanguage,
  }) {
    return AppSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationSoundMode:
          notificationSoundMode ?? this.notificationSoundMode,
      themeMode: themeMode ?? this.themeMode,
      themeStyle: themeStyle ?? this.themeStyle,
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'calculationMethod': calculationMethod.key,
      'notificationsEnabled': notificationsEnabled,
      'notificationSoundMode': notificationSoundMode.key,
      'themeMode': themeMode.key,
      'themeStyle': themeStyle.key,
      'appLanguage': appLanguage.code,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      calculationMethod: CalculationMethodOptionX.fromKey(
        map['calculationMethod'] as String?,
      ),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      notificationSoundMode: NotificationSoundModeX.fromKey(
        map['notificationSoundMode'] as String?,
      ),
      themeMode: ThemeModeOptionX.fromKey(map['themeMode'] as String?),
      themeStyle: ThemeStyleOptionX.fromKey(map['themeStyle'] as String?),
      appLanguage: AppLanguageX.fromCode(map['appLanguage'] as String?),
    );
  }
}
