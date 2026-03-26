import 'package:adhan/adhan.dart';
import 'package:azan_app/core/models/prohibited_time.dart';

class ProhibitedTimeService {
  List<ProhibitedTime> getProhibitedTimes(PrayerTimes pt) {
    final windows = <ProhibitedTime>[
      ProhibitedTime(
        start: pt.sunrise,
        end: pt.sunrise.add(const Duration(minutes: 10)),
        label: 'Sunrise',
      ),
      ProhibitedTime(
        start: pt.dhuhr.subtract(const Duration(minutes: 10)),
        end: pt.dhuhr,
        label: 'Zawal / Istiwa',
      ),
      ProhibitedTime(
        start: pt.maghrib.subtract(const Duration(minutes: 15)),
        end: pt.maghrib,
        label: 'Sunset',
      ),
    ];

    return windows
        .where((window) => window.end.isAfter(window.start))
        .toList(growable: false);
  }

  bool isNowProhibited(DateTime now, List<ProhibitedTime> times) {
    return times.any((window) => _isActive(window: window, now: now));
  }

  ProhibitedTime? currentWindow(DateTime now, List<ProhibitedTime> times) {
    for (final window in times) {
      if (_isActive(window: window, now: now)) {
        return window;
      }
    }
    return null;
  }

  bool _isActive({required ProhibitedTime window, required DateTime now}) {
    return !now.isBefore(window.start) && now.isBefore(window.end);
  }
}
