import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../presentation/controllers/scan_controller.dart';
import '../../../../core/router.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _previewBytes;

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source, maxWidth: 1024);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _previewBytes = bytes);
  }

  @override
  void initState() {
    super.initState();
    // Mulai monitoring jaringan setelah frame pertama untuk memastikan Provider siap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ScanController>().startNetworkMonitoring();
    });
  }

  Future<void> _runScan() async {
    final ctrl = context.read<ScanController>();
    final bytes = _previewBytes;
    if (bytes == null) return;
    await ctrl.scan(bytes);
    final result = ctrl.result;
    if (result != null && mounted) {
      Navigator.pushNamed(context, AppRoutes.scanResult, arguments: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ScanController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (ctrl.isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  border: Border.all(color: Colors.orange.shade700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Offline: periksa koneksi internet sebelum melakukan scan.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Coba lagi',
                      onPressed: ctrl.isOffline ? null : _runScan,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Center(
                child: _previewBytes == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 120,
                        color: Colors.green,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _previewBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            if (ctrl.loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            if (ctrl.error != null)
              Text(
                ctrl.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (!_previewBytesIsReady(ctrl) || ctrl.isOffline)
                    ? null
                    : _runScan,
                child: const Text('Scan Waste'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _previewBytesIsReady(ScanController ctrl) =>
      _previewBytes != null && !ctrl.loading;
}
