import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class HistoryDatabase {
  static const _dbName = 'ecosort_history.db';
  static const _dbVersion = 1;

  static final HistoryDatabase instance = HistoryDatabase._internal();
  HistoryDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE scan_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          created_at INTEGER NOT NULL,
          label TEXT NOT NULL,
          category TEXT NOT NULL,
          is_organic INTEGER NOT NULL,
          accuracy REAL NOT NULL,
          image_path TEXT,
          image_base64 TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_scan_history_created_at ON scan_history(created_at DESC);
        ''');
      },
    );
  }
}
