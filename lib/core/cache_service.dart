import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class CacheService {
  late Database _db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'bpm_cache.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) {
        db.execute('''CREATE TABLE bpm_cache (
          artist TEXT,
          title  TEXT,
          bpm    INTEGER,
          PRIMARY KEY (artist, title)
        )''');
      },
    );
  }

  Future<int?> getBpm(String artist, String title) async {
    final rows = await _db.query(
      'bpm_cache',
      columns: ['bpm'],
      where: 'artist = ? AND title = ?',
      whereArgs: [artist.toLowerCase(), title.toLowerCase()],
    );
    if (rows.isEmpty) return null;
    return rows.first['bpm'] as int?;
  }

  Future<void> saveBpm(String artist, String title, int bpm) async {
    await _db.insert(
      'bpm_cache',
      {
        'artist': artist.toLowerCase(),
        'title': title.toLowerCase(),
        'bpm': bpm,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
