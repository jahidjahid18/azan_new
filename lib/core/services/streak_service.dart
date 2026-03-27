import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/services/hive_service.dart';

class StreakService {
  StreakService({required HiveService hiveService}) : _hiveService = hiveService;

  final HiveService _hiveService;

  int currentStreak() {
    return _hiveService.loadInt(
      key: AppConstants.retentionCurrentStreakStorageKey,
      defaultValue: 0,
    );
  }

  Future<int> recordDailyOpen(DateTime now) async {
    final todayKey = _dateKey(now);
    final lastOpenDateKey = _hiveService.loadString(
      key: AppConstants.retentionLastOpenDateStorageKey,
      defaultValue: '',
    );
    final current = currentStreak();

    if (lastOpenDateKey == todayKey) {
      return current;
    }

    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));
    final nextStreak = lastOpenDateKey == yesterdayKey ? current + 1 : 1;

    await _hiveService.saveString(
      key: AppConstants.retentionLastOpenDateStorageKey,
      value: todayKey,
    );
    await _hiveService.saveInt(
      key: AppConstants.retentionCurrentStreakStorageKey,
      value: nextStreak,
    );
    return nextStreak;
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }
}
