import 'dart:convert';

import 'package:azan_app/features/azkar/data/models/azkar_item.dart';
import 'package:flutter/services.dart';

class AzkarService {
  Map<String, List<AzkarItem>>? _cache;

  Future<Map<String, List<AzkarItem>>> loadAzkar() async {
    if (_cache != null) {
      return _cache!;
    }

    final raw = await rootBundle.loadString('assets/data/azkar.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;

    _cache = <String, List<AzkarItem>>{
      'morning': (map['morning'] as List<dynamic>)
          .map((item) => AzkarItem.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
      'evening': (map['evening'] as List<dynamic>)
          .map((item) => AzkarItem.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
    };

    return _cache!;
  }
}
