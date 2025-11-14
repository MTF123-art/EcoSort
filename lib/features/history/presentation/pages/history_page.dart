import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/bottom_navbar.dart';
import '../../../../core/router.dart';
import '../controllers/history_controller.dart';
import '../../../scan/domain/entities/scan_result.dart' as sr;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear history'),
                  content: const Text(
                    'Delete all scan history? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await context.read<HistoryController>().clear();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Consumer<HistoryController>(
          builder: (context, ctrl, _) {
            if (ctrl.loading && ctrl.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (ctrl.error != null) {
              return Center(child: Text('Error: ${ctrl.error}'));
            }
            if (ctrl.items.isEmpty) {
              return const Center(child: Text('No scan history yet'));
            }
            return ListView.builder(
              itemCount: ctrl.items.length,
              itemBuilder: (context, index) {
                final h = ctrl.items[index];
                final sub =
                    '${h.category} • ${h.isOrganic ? 'Organic' : 'Non-Organic'}';
                final date = _timeAgo(h.createdAt);
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final type = h.isOrganic
                        ? 'Organic Waste'
                        : 'Non-Organic Waste';
                    final result = sr.ScanResult(
                      name: h.label,
                      category: h.category,
                      type: type,
                      accuracy: h.accuracy,
                      isOrganic: h.isOrganic,
                      rawLabel: h.label,
                      description: h.isOrganic
                          ? 'Organic material that breaks down naturally and is suitable for compost.'
                          : 'Non-organic waste. Consider proper recycling based on its type.',
                      imageUrl: '',
                      imageBytes: h.imageBytes,
                      ecoTips: const [],
                      reuseIdeas: const [],
                      ecoFacts: const [],
                    );
                    Navigator.pushNamed(
                      context,
                      AppRoutes.scanResult,
                      arguments: result,
                    );
                  },
                  child: _HistoryCard(
                    title: h.label,
                    subtitle: sub,
                    date: date,
                    imagePath: h.imagePath,
                    imageBytes: h.imageBytes,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String? imagePath;
  final Uint8List? imageBytes;
  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.date,
    this.imagePath,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.greenAccent.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: _thumb(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(date, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb() {
    const w = 110.0;
    const h = 90.0;
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Hero(
        tag: _heroTagFromBytes(imageBytes!),
        child: Image.memory(
          imageBytes!,
          width: w,
          height: h,
          fit: BoxFit.cover,
        ),
      );
    }
    if (imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync()) {
      return Image.file(
        File(imagePath!),
        width: w,
        height: h,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: w,
      height: h,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: Colors.black45),
    );
  }
}

String _timeAgo(DateTime ts) {
  final d = DateTime.now().difference(ts);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = (ts.month >= 1 && ts.month <= 12) ? names[ts.month - 1] : '';
  return '$month ${ts.day}';
}

String _heroTagFromBytes(Uint8List bytes) {
  if (bytes.isEmpty) return 'hero_empty';
  final l = bytes.length;
  final a = bytes.first;
  final b = bytes.last;
  return 'hero_${l}_${a}_${b}';
}
