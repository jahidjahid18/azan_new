import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';

class AppSettings {
  const AppSettings({
    required this.calculationMethod,
    required this.notificationsEnabled,
    required this.notificationSoundMode,
    required this.themeMode,
  });

  final CalculationMethodOption calculationMethod;
  final bool notificationsEnabled;
  final NotificationSoundMode notificationSoundMode;
  final ThemeModeOption themeMode;

  factory AppSettings.defaults() {
    return const AppSettings(
      calculationMethod: CalculationMethodOption.muslimWorldLeague,
      notificationsEnabled: true,
      notificationSoundMode: NotificationSoundMode.notificationOnly,
      themeMode: ThemeModeOption.system,
    );
  }

  AppSettings copyWith({
    CalculationMethodOption? calculationMethod,
    bool? notificationsEnabled,
    NotificationSoundMode? notificationSoundMode,
    ThemeModeOption? themeMode,
  }) {
    return AppSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationSoundMode:
          notificationSoundMode ?? this.notificationSoundMode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'calculationMethod': calculationMethod.key,
      'notificationsEnabled': notificationsEnabled,
      'notificationSoundMode': notificationSoundMode.key,
      'themeMode': themeMode.key,
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
    );
  }
}
