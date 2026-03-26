class ProhibitedTime {
  const ProhibitedTime({
    required this.start,
    required this.end,
    required this.label,
  });

  final DateTime start;
  final DateTime end;
  final String label;
}
