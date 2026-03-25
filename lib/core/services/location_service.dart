import 'package:azan_app/core/models/app_location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationService {
  Future<AppLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location service is disabled. Please enable GPS.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Enable it from App Settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final cityName = await _resolveCity(position.latitude, position.longitude);
    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
    );
  }

  Future<AppLocation> fromManualCoordinates({
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    final trimmedCity = cityName.trim();
    if (trimmedCity.isNotEmpty) {
      return AppLocation(
        latitude: latitude,
        longitude: longitude,
        cityName: trimmedCity,
      );
    }

    final resolvedCity = await _resolveCity(latitude, longitude);
    return AppLocation(
      latitude: latitude,
      longitude: longitude,
      cityName: resolvedCity,
    );
  }

  Future<String> _resolveCity(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locality = place.locality?.trim();
        final subAdministrative = place.subAdministrativeArea?.trim();
        final country = place.country?.trim();

        if (locality != null && locality.isNotEmpty) {
          return locality;
        }
        if (subAdministrative != null && subAdministrative.isNotEmpty) {
          return subAdministrative;
        }
        if (country != null && country.isNotEmpty) {
          return country;
        }
      }
    } catch (_) {
      // Reverse geocoding may fail offline; coordinates are used as fallback.
    }

    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }
}
