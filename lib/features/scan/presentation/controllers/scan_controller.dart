import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/scan_repository.dart';
import '../../domain/entities/scan_result.dart';
import '../../../history/data/history_repository.dart';

class ScanController extends ChangeNotifier {
  late ScanRepository _repo;
  bool _attached = false;
  HistoryRepository? _history;

  ScanResult? result;
  bool loading = false;
  Object? error;
  bool isOffline = false;

  StreamSubscription<List<ConnectivityResult>>? _connSub;

  void startNetworkMonitoring() {
    // Hindari set up berulang
    if (_connSub != null) return;
    _connSub = Connectivity().onConnectivityChanged.listen((events) {
      // Versi baru bisa mengembalikan daftar hasil; tentukan offline jika semua none atau list kosong
      final offline =
          events.isEmpty || events.every((e) => e == ConnectivityResult.none);
      if (offline != isOffline) {
        isOffline = offline;
        // Jika offline, hentikan loading yang sedang berjalan agar UI responsif
        if (isOffline && loading) {
          loading = false;
          error = OfflineException();
          result = null;
        }
        notifyListeners();
      }
    });
    // Cek awal
    Connectivity().checkConnectivity().then((events) {
      final offline =
          events.isEmpty || events.every((e) => e == ConnectivityResult.none);
      if (offline != isOffline) {
        isOffline = offline;
        notifyListeners();
      }
    });
  }

  void attach(ScanRepository repo) {
    _repo = repo;
    _attached = true;
  }

  void attachHistory(HistoryRepository historyRepository) {
    _history = historyRepository;
  }

  Future<void> scan(Uint8List bytes) async {
    if (!_attached) {
      throw StateError('ScanRepository belum terpasang');
    }
    if (loading) return;
    if (isOffline) {
      // Langsung fail cepat jika offline
      error = OfflineException();
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    result = null;
    notifyListeners();
    try {
      final r = await _repo.classify(bytes);
      result = r;
      // Persist to history if available
      final history = _history;
      if (history != null) {
        await history.addFromScanResult(r);
      }
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void reset() {
    result = null;
    error = null;
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }
}

class OfflineException implements Exception {
  @override
  String toString() => 'Perangkat offline. Mohon periksa koneksi internet.';
}
