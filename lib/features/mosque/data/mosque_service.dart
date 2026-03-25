import 'dart:convert';

import 'package:azan_app/features/mosque/data/models/mosque_place.dart';
import 'package:http/http.dart' as http;

class MosqueService {
  Future<List<MosquePlace>> fetchNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusMeters = 3000,
  }) async {
    final query =
        '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
);
out center 50;
''';

    final response = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load mosques right now.');
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = map['elements'] as List<dynamic>? ?? <dynamic>[];

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
      final name = tags['name'] as String? ?? 'Mosque';
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

  String _addressFromTags(Map<String, dynamic> tags) {
    final street = tags['addr:street'] as String? ?? '';
    final city = tags['addr:city'] as String? ?? '';
    final state = tags['addr:state'] as String? ?? '';

    final parts = <String>[
      street,
      city,
      state,
    ].where((value) => value.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Address unavailable' : parts.join(', ');
  }
}
