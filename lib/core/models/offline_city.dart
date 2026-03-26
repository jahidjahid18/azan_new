class OfflineCity {
  OfflineCity({
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
  }) : _nameLower = name.toLowerCase(),
       _searchableLower =
           '${name.toLowerCase()} ${country.toLowerCase()} ${region.toLowerCase()}';

  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;
  final String _nameLower;
  final String _searchableLower;

  String get displayName => '$name, $country';

  bool startsWithQuery(String queryLower) {
    return _nameLower.startsWith(queryLower);
  }

  bool containsQuery(String queryLower) {
    return _searchableLower.contains(queryLower);
  }

  factory OfflineCity.fromMap(Map<String, dynamic> map) {
    return OfflineCity(
      name: (map['name'] as String).trim(),
      country: (map['country'] as String).trim(),
      region: ((map['region'] as String?) ?? '').trim(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}
