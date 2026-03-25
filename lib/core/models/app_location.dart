class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  final double latitude;
  final double longitude;
  final String cityName;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
    };
  }

  factory AppLocation.fromMap(Map<String, dynamic> map) {
    return AppLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      cityName: (map['cityName'] as String?)?.trim().isNotEmpty == true
          ? map['cityName'] as String
          : 'Unknown location',
    );
  }
}
