import 'dart:convert';

import 'package:azan_app/features/mosque/data/models/mosque_place.dart';
import 'package:http/http.dart' as http;

class MosqueService {
  static const String _defaultGooglePlacesApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String _googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: _defaultGooglePlacesApiKey,
  );

  Future<List<MosquePlace>> fetchNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusMeters = 3000,
    String keyword = 'mosque',
  }) async {
    if (_googlePlacesApiKey.isEmpty ||
        _googlePlacesApiKey == _defaultGooglePlacesApiKey) {
      throw Exception('Google Places API key is missing.');
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/nearbysearch/json',
      <String, String>{
        'location': '$latitude,$longitude',
        'radius': '$radiusMeters',
        'keyword': keyword,
        'key': _googlePlacesApiKey,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Unable to load mosques right now.');
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final status = map['status'] as String? ?? 'UNKNOWN_ERROR';

    if (status == 'ZERO_RESULTS') {
      return <MosquePlace>[];
    }

    if (status != 'OK') {
      final errorMessage = map['error_message'] as String?;
      if (errorMessage != null && errorMessage.trim().isNotEmpty) {
        throw Exception(errorMessage);
      }
      throw Exception('Unable to load mosques right now.');
    }

    final results = map['results'] as List<dynamic>? ?? <dynamic>[];
    return _extractPlaces(results);
  }

  List<MosquePlace> _extractPlaces(List<dynamic> elements) {
    final places = <MosquePlace>[];
    final dedupe = <String>{};

    for (final item in elements) {
      final element = item as Map<String, dynamic>;
      final geometry = element['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = location?['lat'] as num?;
      final lon = location?['lng'] as num?;
      if (lat == null || lon == null) continue;

      final key = '${lat.toStringAsFixed(5)},${lon.toStringAsFixed(5)}';
      if (dedupe.contains(key)) continue;
      dedupe.add(key);

      final name = (element['name'] as String?)?.trim().isNotEmpty == true
          ? element['name'] as String
          : 'Mosque';
      final address =
          (element['vicinity'] as String?) ??
          (element['formatted_address'] as String?) ??
          'Address unavailable';

      places.add(
        MosquePlace(
          name: name,
          latitude: lat.toDouble(),
          longitude: lon.toDouble(),
          address: address,
        ),
      );
    }

    return places;
  }
}
