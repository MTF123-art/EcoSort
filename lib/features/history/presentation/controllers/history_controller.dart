import 'package:flutter/foundation.dart';
import '../../data/history_repository.dart';
import '../../domain/entities/scan_history_item.dart';

class HistoryController extends ChangeNotifier {
  HistoryRepository? _repo;
  void attach(HistoryRepository repo) => _repo = repo;

  bool loading = false;
  String? error;
  List<ScanHistoryItem> items = [];

  Future<void> load() async {
    final repo = _repo;
    if (repo == null) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await repo.list(limit: 50);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    final repo = _repo;
    if (repo == null) return;
    await repo.clear();
    await load();
  }
}
