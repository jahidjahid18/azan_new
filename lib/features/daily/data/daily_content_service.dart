import 'dart:convert';

import 'package:azan_app/features/daily/data/models/daily_content_item.dart';
import 'package:flutter/services.dart';

class DailyContentService {
  List<DailyContentItem>? _cache;

  Future<DailyContentItem> getContentForDate(DateTime date) async {
    final items = await _loadItems();
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dayIndex =
        normalizedDate.millisecondsSinceEpoch ~/
        const Duration(days: 1).inMilliseconds;
    final selectedIndex = dayIndex % items.length;
    return items[selectedIndex];
  }

  Future<List<DailyContentItem>> _loadItems() async {
    if (_cache != null) {
      return _cache!;
    }

    final raw = await rootBundle.loadString('assets/data/daily_content.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = (map['items'] as List<dynamic>)
        .map((item) => DailyContentItem.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
    _cache = list;
    return _cache!;
  }
}
