import 'dart:convert';

import 'package:azan_app/features/mosque/data/models/mosque_place.dart';
import 'package:http/http.dart' as http;

class MosqueService {
  static const List<String> _overpassEndpoints = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.ru/api/interpreter',
  ];

  Future<List<MosquePlace>> fetchNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusMeters = 3000,
  }) async {
    final strictQuery = _buildStrictQuery(
      radiusMeters: radiusMeters,
      latitude: latitude,
      longitude: longitude,
    );
    final broadQuery = _buildBroadQuery(
      radiusMeters: radiusMeters < 5000 ? 5000 : radiusMeters,
      latitude: latitude,
      longitude: longitude,
    );

    final strictResult = await _queryWithFallbackEndpoints(strictQuery);
    if (strictResult.isNotEmpty) {
      return strictResult;
    }

    final broadResult = await _queryWithFallbackEndpoints(broadQuery);
    if (broadResult.isNotEmpty) {
      return broadResult;
    }

    throw Exception('Unable to load mosques right now.');
  }

  Future<List<MosquePlace>> _queryWithFallbackEndpoints(String query) async {
    for (final endpoint in _overpassEndpoints) {
      try {
        final response = await http
            .post(Uri.parse(endpoint), body: <String, String>{'data': query})
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          continue;
        }

        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final elements = map['elements'] as List<dynamic>? ?? <dynamic>[];
        final places = _extractPlaces(elements);
        if (places.isNotEmpty) {
          return places;
        }
      } catch (_) {
        continue;
      }
    }

    return <MosquePlace>[];
  }

  List<MosquePlace> _extractPlaces(List<dynamic> elements) {
    final places = <MosquePlace>[];
    final dedupe = <String>{};

    for (final item in elements) {
      final element = item as Map<String, dynamic>;
      final lat = (element['lat'] ?? element['center']?['lat']) as num?;
      final lon = (element['lon'] ?? element['center']?['lon']) as num?;
      if (lat == null || lon == null) continue;

      final key = '${lat.toStringAsFixed(5)},${lon.toStringAsFixed(5)}';
      if (dedupe.contains(key)) continue;
      dedupe.add(key);

      final tags =
          element['tags'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final name = (tags['name'] as String?)?.trim().isNotEmpty == true
          ? tags['name'] as String
          : 'Mosque';
      final address = _addressFromTags(tags);

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

  String _buildStrictQuery({
    required int radiusMeters,
    required double latitude,
    required double longitude,
  }) {
    return '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  node["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
);
out center 80;
''';
  }

  String _buildBroadQuery({
    required int radiusMeters,
    required double latitude,
    required double longitude,
  }) {
    return '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["name"~"mosque|masjid|surau|musolla", i](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["name"~"mosque|masjid|surau|musolla", i](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="place_of_worship"]["name"~"mosque|masjid|surau|musolla", i](around:$radiusMeters,$latitude,$longitude);
  node["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
  way["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
  relation["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
);
out center 120;
''';
  }

  String _addressFromTags(Map<String, dynamic> tags) {
    final street = tags['addr:street'] as String? ?? '';
    final city = tags['addr:city'] as String? ?? '';
    final state = tags['addr:state'] as String? ?? '';
    final suburb = tags['addr:suburb'] as String? ?? '';
    final district = tags['addr:district'] as String? ?? '';

    final parts = <String>[
      street,
      suburb,
      district,
      city,
      state,
    ].where((value) => value.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Address unavailable' : parts.join(', ');
  }
}
