import 'package:adhan/adhan.dart';
import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/models/prayer_info.dart';

class PrayerService {
  List<PrayerInfo> getDisplayTimesForDate({
    required AppLocation location,
    required DateTime date,
    required CalculationMethodOption calculationMethod,
  }) {
    final prayerTimes = _buildPrayerTimes(
      location: location,
      date: date,
      calculationMethod: calculationMethod,
    );

    return <PrayerInfo>[
      PrayerInfo(name: 'Fajr', time: prayerTimes.fajr),
      PrayerInfo(
        name: 'Sunrise',
        time: prayerTimes.sunrise,
        isObligatory: false,
      ),
      PrayerInfo(name: 'Dhuhr', time: prayerTimes.dhuhr),
      PrayerInfo(name: 'Asr', time: prayerTimes.asr),
      PrayerInfo(name: 'Maghrib', time: prayerTimes.maghrib),
      PrayerInfo(name: 'Isha', time: prayerTimes.isha),
    ];
  }

  List<PrayerInfo> getObligatoryPrayerTimesForDate({
    required AppLocation location,
    required DateTime date,
    required CalculationMethodOption calculationMethod,
  }) {
    return getDisplayTimesForDate(
      location: location,
      date: date,
      calculationMethod: calculationMethod,
    ).where((prayer) => prayer.isObligatory).toList();
  }

  PrayerInfo getNextPrayer({
    required AppLocation location,
    required DateTime now,
    required CalculationMethodOption calculationMethod,
    required List<PrayerInfo> todayObligatoryPrayers,
  }) {
    for (final prayer in todayObligatoryPrayers) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }

    final tomorrowPrayers = getObligatoryPrayerTimesForDate(
      location: location,
      date: now.add(const Duration(days: 1)),
      calculationMethod: calculationMethod,
    );
    return tomorrowPrayers.first;
  }

  List<PrayerInfo> getUpcomingPrayers({
    required AppLocation location,
    required CalculationMethodOption calculationMethod,
    required int numberOfDays,
  }) {
    final now = DateTime.now();
    final upcoming = <PrayerInfo>[];

    for (var dayOffset = 0; dayOffset < numberOfDays; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final prayers = getObligatoryPrayerTimesForDate(
        location: location,
        date: date,
        calculationMethod: calculationMethod,
      );

      for (final prayer in prayers) {
        if (prayer.time.isAfter(now)) {
          upcoming.add(prayer);
        }
      }
    }

    return upcoming;
  }

  PrayerTimes _buildPrayerTimes({
    required AppLocation location,
    required DateTime date,
    required CalculationMethodOption calculationMethod,
  }) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    final params = calculationMethod.adhanMethod.getParameters();
    params.madhab = Madhab.shafi;

    return PrayerTimes(
      coordinates,
      DateComponents(date.year, date.month, date.day),
      params,
    );
  }
}
