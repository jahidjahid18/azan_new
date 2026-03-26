import 'package:azan_app/core/models/app_location.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class LocationSqliteService {
  static const String _databaseName = 'azan_location.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'selected_location';

  Database? _database;

  Future<void> saveLocation(AppLocation location) async {
    final db = await _openDatabase();
    await db.insert(_tableName, <String, Object?>{
      'id': 1,
      'city_name': location.cityName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppLocation?> loadLocation() async {
    final db = await _openDatabase();
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: <int>[1],
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return AppLocation(
      cityName: row['city_name'] as String? ?? 'Unknown location',
      latitude: (row['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (row['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<Database> _openDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _databaseName);
    _database = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            city_name TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }
}
