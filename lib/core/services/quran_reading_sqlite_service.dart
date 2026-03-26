import 'package:azan_app/features/quran/data/models/quran_read_position.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class QuranReadingSqliteService {
  static const String _databaseName = 'azan_quran_reading.db';
  static const int _databaseVersion = 1;
  static const String _dailyTableName = 'quran_daily_reading';
  static const String _lastReadTableName = 'quran_last_read';

  Database? _database;

  Future<int> getActiveSecondsForDate(String dateKey) async {
    final db = await _openDatabase();
    final rows = await db.query(
      _dailyTableName,
      columns: <String>['active_seconds'],
      where: 'date_key = ?',
      whereArgs: <String>[dateKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return 0;
    }
    return (rows.first['active_seconds'] as num?)?.toInt() ?? 0;
  }

  Future<void> incrementActiveSecondsForDate({
    required String dateKey,
    required int seconds,
  }) async {
    if (seconds <= 0) return;
    final db = await _openDatabase();
    final nowIso = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final existing = await txn.query(
        _dailyTableName,
        columns: <String>['active_seconds'],
        where: 'date_key = ?',
        whereArgs: <String>[dateKey],
        limit: 1,
      );
      if (existing.isEmpty) {
        await txn.insert(_dailyTableName, <String, Object?>{
          'date_key': dateKey,
          'active_seconds': seconds,
          'updated_at': nowIso,
        });
        return;
      }

      final current = (existing.first['active_seconds'] as num?)?.toInt() ?? 0;
      await txn.update(
        _dailyTableName,
        <String, Object?>{
          'active_seconds': current + seconds,
          'updated_at': nowIso,
        },
        where: 'date_key = ?',
        whereArgs: <String>[dateKey],
      );
    });
  }

  Future<void> saveLastReadPosition(QuranReadPosition position) async {
    final db = await _openDatabase();
    await db.insert(_lastReadTableName, <String, Object?>{
      'id': 1,
      'surah_number': position.surahNumber,
      'ayah_number': position.ayahNumber,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<QuranReadPosition?> loadLastReadPosition() async {
    final db = await _openDatabase();
    final rows = await db.query(
      _lastReadTableName,
      where: 'id = ?',
      whereArgs: <int>[1],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return QuranReadPosition(
      surahNumber: (row['surah_number'] as num?)?.toInt() ?? 1,
      ayahNumber: (row['ayah_number'] as num?)?.toInt() ?? 1,
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
          CREATE TABLE $_dailyTableName (
            date_key TEXT PRIMARY KEY,
            active_seconds INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_lastReadTableName (
            id INTEGER PRIMARY KEY,
            surah_number INTEGER NOT NULL,
            ayah_number INTEGER NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }
}
