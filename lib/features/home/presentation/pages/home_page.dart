import 'dart:math' as math;
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/bottom_navbar.dart';
import '../../../../core/router.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../history/domain/entities/scan_history_item.dart';
import '../../../scan/domain/entities/scan_result.dart' as sr;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loaded = false;

  void _openScan(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.scan);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      // Trigger initial history load once when the widget appears
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<HistoryController>().load();
      });
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade100,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.eco, color: Colors.green, size: 36),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'EcoSort',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Instant waste recognition',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = MediaQuery.of(context).size.height;
          final heroHeight = math.min(480.0, screenHeight * 0.45);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                right: 16,
                left: 16,
                top: 16,
                bottom: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero section with image + gradient overlay
                    Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          width: double.infinity,
                          height: heroHeight,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/ilustrasi-ecosort.png',
                                  fit: BoxFit.cover,
                                ),
                                // Gradient overlay for better text contrast
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.0),
                                          Colors.black.withOpacity(0.45),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 24,
                            bottom: 20,
                            right: 24,
                          ),
                          child: Text(
                            'Scan. Sort.\nSave the planet.',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openScan(context),
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Scan or Upload Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Scans',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.history),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      child: Consumer<HistoryController>(
                        builder: (context, hc, _) {
                          if (hc.loading) {
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          if (hc.items.isEmpty) {
                            return Center(
                              child: Text(
                                'No scan history yet',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }
                          final items = hc.items.take(10).toList();
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) => _RecentCard(item: items[i]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final ScanHistoryItem item;
  const _RecentCard({required this.item});

  void _openResult(BuildContext context) {
    final type = item.isOrganic ? 'Organic Waste' : 'Non-Organic Waste';
    final result = sr.ScanResult(
      name: item.label,
      category: item.category,
      type: type,
      accuracy: item.accuracy,
      isOrganic: item.isOrganic,
      rawLabel: item.label,
      description: item.isOrganic
          ? 'Organic material that breaks down naturally and is suitable for compost.'
          : 'Non-organic waste. Consider proper recycling based on its type.',
      imageUrl: '',
      imageBytes: item.imageBytes,
      ecoTips: const [],
      reuseIdeas: const [],
      ecoFacts: const [],
    );
    Navigator.pushNamed(context, AppRoutes.scanResult, arguments: result);
  }

  String _timeAgo(DateTime ts) {
    final d = DateTime.now().difference(ts);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    final month = _monthAbbr(ts.month);
    return '$month ${ts.day}';
  }

  String _monthAbbr(int m) {
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
    return (m >= 1 && m <= 12) ? names[m - 1] : '';
  }

  String _heroTag() {
    final bytes = item.imageBytes;
    if (bytes != null && bytes.isNotEmpty) {
      final l = bytes.length;
      final a = bytes.first;
      final b = bytes.last;
      return 'hero_${l}_${a}_${b}';
    }
    return 'hero_${item.label}_${item.createdAt.millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openResult(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 240,
        decoration: BoxDecoration(
          color: Colors.greenAccent.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Hero(
                tag: _heroTag(),
                child: _RecentImage(item: item),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.eco,
                            size: 14,
                            color: item.isOrganic ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isOrganic ? 'Organic' : 'Non-Organic',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    _timeAgo(item.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentImage extends StatelessWidget {
  final ScanHistoryItem item;
  const _RecentImage({required this.item});

  @override
  Widget build(BuildContext context) {
    const double h = 90;
    if (item.imageBytes != null && item.imageBytes!.isNotEmpty) {
      return Image.memory(
        item.imageBytes!,
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      final file = File(item.imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: h,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      }
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    height: 90,
    color: Colors.grey.shade300,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image),
  );
}
