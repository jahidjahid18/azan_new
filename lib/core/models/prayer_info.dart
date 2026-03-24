class PrayerInfo {
  const PrayerInfo({
    required this.name,
    required this.time,
    this.isObligatory = true,
  });

  final String name;
  final DateTime time;
  final bool isObligatory;
}
