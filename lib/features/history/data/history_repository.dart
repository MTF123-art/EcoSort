import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'history_database.dart';
import '../../scan/domain/entities/scan_result.dart' as sr show ScanResult;
import '../domain/entities/scan_history_item.dart';

class HistoryRepository {
  final HistoryDatabase db;
  HistoryRepository(this.db);

  Future<void> add(ScanHistoryItem item, {int maxItems = 50}) async {
    final database = await db.database;
    await database.insert(
      'scan_history',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _prune(maxItems);
  }

  Future<void> addFromScanResult(
    sr.ScanResult result, {
    int maxItems = 50,
  }) async {
    String? imagePath;
    Uint8List? bytes = result.imageBytes;
    String? b64;
    if (bytes != null && bytes.isNotEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(p.join(dir.path, 'history'));
      if (!await folder.exists()) await folder.create(recursive: true);
      final fname = 'scan_${DateTime.now().millisecondsSinceEpoch}.png';
      final fpath = p.join(folder.path, fname);
      final file = File(fpath);
      await file.writeAsBytes(bytes, flush: true);
      imagePath = fpath;
      b64 = base64Encode(bytes);
    }

    final item = ScanHistoryItem(
      createdAt: DateTime.now(),
      label: result.name,
      category: result.category,
      isOrganic: result.isOrganic,
      accuracy: result.accuracy,
      imagePath: imagePath,
      imageBytes: bytes,
    );

    final database = await db.database;
    await database.insert(
      'scan_history',
      item.toMap(imageBase64: b64),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _prune(maxItems);
  }

  Future<List<ScanHistoryItem>> list({int limit = 50}) async {
    final database = await db.database;
    final rows = await database.query(
      'scan_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map((r) {
      final base64 = r['image_base64'] as String?;
      final bytes = (base64 != null && base64.isNotEmpty)
          ? base64Decode(base64)
          : null;
      return ScanHistoryItem.fromMap(r, bytes: bytes);
    }).toList();
  }

  Future<void> clear() async {
    final database = await db.database;
    await database.delete('scan_history');
  }

  Future<void> _prune(int maxItems) async {
    final database = await db.database;
    final countRaw =
        Sqflite.firstIntValue(
          await database.rawQuery('SELECT COUNT(*) FROM scan_history'),
        ) ??
        0;
    final overflow = countRaw - maxItems;
    if (overflow > 0) {
      await database.execute(
        'DELETE FROM scan_history WHERE id IN (SELECT id FROM scan_history ORDER BY created_at DESC LIMIT -1 OFFSET ?)',
        [maxItems],
      );
    }
  }
}
