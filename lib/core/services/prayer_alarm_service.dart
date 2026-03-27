import 'dart:io';

import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/models/prayer_info.dart';
import 'package:flutter/services.dart';

class PrayerAlarmService {
  static const MethodChannel _channel = MethodChannel('azan_app/prayer_alarm');

  Future<void> schedulePrayerAlarms({
    required bool enabled,
    required NotificationSoundMode soundMode,
    required List<PrayerInfo> upcomingPrayers,
    required String locationName,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    final prayers = upcomingPrayers
        .map(
          (p) => <String, dynamic>{
            'name': p.name,
            'timeMillis': p.time.millisecondsSinceEpoch,
          },
        )
        .toList(growable: false);

    await _channel.invokeMethod<void>('schedulePrayerAlarms', <String, dynamic>{
      'enabled': enabled,
      'soundMode': soundMode.key,
      'locationName': locationName,
      'prayers': prayers,
    });
  }

  Future<void> cancelPrayerAlarms() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _channel.invokeMethod<void>('cancelPrayerAlarms');
  }

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final allowed = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
    return allowed ?? false;
  }
}
