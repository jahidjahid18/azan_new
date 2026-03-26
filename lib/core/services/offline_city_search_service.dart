import 'dart:convert';

import 'package:azan_app/core/models/offline_city.dart';
import 'package:flutter/services.dart';

class OfflineCitySearchService {
  OfflineCitySearchService._();

  static final OfflineCitySearchService instance = OfflineCitySearchService._();
  static const String _assetPath = 'assets/data/cities_global.json';

  List<OfflineCity>? _cities;
  Future<void>? _loadFuture;

  Future<void> ensureLoaded() {
    if (_cities != null) {
      return Future<void>.value();
    }
    if (_loadFuture != null) {
      return _loadFuture!;
    }
    _loadFuture = _loadCities();
    return _loadFuture!;
  }

  Future<List<OfflineCity>> searchCities(String query, {int limit = 15}) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const <OfflineCity>[];
    }

    await ensureLoaded();
    final cities = _cities ?? const <OfflineCity>[];
    if (cities.isEmpty) {
      return const <OfflineCity>[];
    }

    final startsWith = <OfflineCity>[];
    final contains = <OfflineCity>[];

    for (final city in cities) {
      final starts = city.startsWithQuery(normalizedQuery);
      final matches = starts || city.containsQuery(normalizedQuery);

      if (starts) {
        startsWith.add(city);
      } else if (matches) {
        contains.add(city);
      }
    }

    final ranked = <OfflineCity>[...startsWith, ...contains];
    if (ranked.length <= limit) {
      return ranked;
    }
    return ranked.sublist(0, limit);
  }

  Future<void> _loadCities() async {
    try {
      final rawJson = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        _cities = const <OfflineCity>[];
        return;
      }
      _cities = decoded
          .whereType<Map>()
          .map((item) => OfflineCity.fromMap(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    } catch (_) {
      _cities = const <OfflineCity>[];
    } finally {
      _loadFuture = null;
    }
  }
}
