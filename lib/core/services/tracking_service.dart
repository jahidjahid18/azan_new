import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/services/hive_service.dart';

class TrackingService {
  TrackingService({required HiveService hiveService}) : _hiveService = hiveService;

  final HiveService _hiveService;

  int dailyTasbihCount(DateTime date) {
    final tracker = _hiveService.loadMap(
      key: AppConstants.dailyTasbihTrackerStorageKey,
    );
    return tracker[_dateKey(date)] as int? ?? 0;
  }

  Future<int> incrementDailyTasbih(DateTime date) async {
    final tracker = _hiveService.loadMap(
      key: AppConstants.dailyTasbihTrackerStorageKey,
    );
    final key = _dateKey(date);
    final current = tracker[key] as int? ?? 0;
    final next = current + 1;
    tracker[key] = next;
    await _hiveService.saveMap(
      key: AppConstants.dailyTasbihTrackerStorageKey,
      value: tracker,
    );
    return next;
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }
}
