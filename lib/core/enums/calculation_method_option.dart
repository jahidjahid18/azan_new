import 'package:adhan/adhan.dart';

enum CalculationMethodOption {
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  dubai,
  moonSightingCommittee,
  northAmerica,
  kuwait,
  qatar,
  singapore,
  turkey,
  tehran,
}

extension CalculationMethodOptionX on CalculationMethodOption {
  String get key => switch (this) {
    CalculationMethodOption.muslimWorldLeague => 'muslim_world_league',
    CalculationMethodOption.egyptian => 'egyptian',
    CalculationMethodOption.karachi => 'karachi',
    CalculationMethodOption.ummAlQura => 'umm_al_qura',
    CalculationMethodOption.dubai => 'dubai',
    CalculationMethodOption.moonSightingCommittee => 'moon_sighting_committee',
    CalculationMethodOption.northAmerica => 'north_america',
    CalculationMethodOption.kuwait => 'kuwait',
    CalculationMethodOption.qatar => 'qatar',
    CalculationMethodOption.singapore => 'singapore',
    CalculationMethodOption.turkey => 'turkey',
    CalculationMethodOption.tehran => 'tehran',
  };

  String get label => switch (this) {
    CalculationMethodOption.muslimWorldLeague => 'Muslim World League',
    CalculationMethodOption.egyptian => 'Egyptian',
    CalculationMethodOption.karachi => 'Karachi',
    CalculationMethodOption.ummAlQura => 'Umm Al-Qura',
    CalculationMethodOption.dubai => 'Dubai',
    CalculationMethodOption.moonSightingCommittee => 'Moon Sighting Committee',
    CalculationMethodOption.northAmerica => 'North America (ISNA)',
    CalculationMethodOption.kuwait => 'Kuwait',
    CalculationMethodOption.qatar => 'Qatar',
    CalculationMethodOption.singapore => 'Singapore',
    CalculationMethodOption.turkey => 'Turkey',
    CalculationMethodOption.tehran => 'Tehran',
  };

  CalculationMethod get adhanMethod => switch (this) {
    CalculationMethodOption.muslimWorldLeague =>
      CalculationMethod.muslim_world_league,
    CalculationMethodOption.egyptian => CalculationMethod.egyptian,
    CalculationMethodOption.karachi => CalculationMethod.karachi,
    CalculationMethodOption.ummAlQura => CalculationMethod.umm_al_qura,
    CalculationMethodOption.dubai => CalculationMethod.dubai,
    CalculationMethodOption.moonSightingCommittee =>
      CalculationMethod.moon_sighting_committee,
    CalculationMethodOption.northAmerica => CalculationMethod.north_america,
    CalculationMethodOption.kuwait => CalculationMethod.kuwait,
    CalculationMethodOption.qatar => CalculationMethod.qatar,
    CalculationMethodOption.singapore => CalculationMethod.singapore,
    CalculationMethodOption.turkey => CalculationMethod.turkey,
    CalculationMethodOption.tehran => CalculationMethod.tehran,
  };

  static CalculationMethodOption fromKey(String? value) {
    return CalculationMethodOption.values.firstWhere(
      (method) => method.key == value,
      orElse: () => CalculationMethodOption.muslimWorldLeague,
    );
  }
}
