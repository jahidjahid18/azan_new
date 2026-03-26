import 'package:adhan/adhan.dart';
import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/models/app_location.dart';
import 'package:azan_app/core/models/prohibited_time.dart';
import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/services/prohibited_time_service.dart';

class PrayerService {
  final ProhibitedTimeService _prohibitedTimeService = ProhibitedTimeService();

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
    final sunnahTimes = SunnahTimes(prayerTimes);

    return <PrayerInfo>[
      PrayerInfo(
        name: 'Imsak',
        time: prayerTimes.fajr.subtract(const Duration(minutes: 10)),
        isObligatory: false,
      ),
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
      PrayerInfo(
        name: 'Midnight',
        time: sunnahTimes.middleOfTheNight,
        isObligatory: false,
      ),
      PrayerInfo(
        name: 'Qiyam',
        time: sunnahTimes.lastThirdOfTheNight,
        isObligatory: false,
      ),
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

  List<ProhibitedTime> getProhibitedTimesForDate({
    required AppLocation location,
    required DateTime date,
    required CalculationMethodOption calculationMethod,
  }) {
    final prayerTimes = _buildPrayerTimes(
      location: location,
      date: date,
      calculationMethod: calculationMethod,
    );
    return _prohibitedTimeService.getProhibitedTimes(prayerTimes);
  }

  bool isNowProhibited({
    required DateTime now,
    required List<ProhibitedTime> prohibitedTimes,
  }) {
    return _prohibitedTimeService.isNowProhibited(now, prohibitedTimes);
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
