import 'package:flutter/material.dart';
import '../../domain/entities/scan_result.dart';
import '../widgets/result_sections.dart';
import '../../../../core/widgets/bottom_navbar.dart';

class ScanResultPage extends StatelessWidget {
  final ScanResult result;
  const ScanResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final ecoTips = result.ecoTips.isNotEmpty
        ? result.ecoTips
        : _ecoTipsFallback(result);
    final reuseIdeas = result.reuseIdeas.isNotEmpty
        ? result.reuseIdeas
        : _reuseIdeasFallback(result);
    final ecoFacts = result.ecoFacts.isNotEmpty
        ? result.ecoFacts
        : _ecoFactsFallback(result);
    return Scaffold(
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Scan Result',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Here's what we found!",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _ResultHeaderCard(result: result),
              const SizedBox(height: 12),
              Text(result.description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Scan Another'),
                ),
              ),
              const SizedBox(height: 16),
              ResultSection(
                title: 'Eco tips',
                icon: Icons.science_outlined,
                items: ecoTips,
              ),
              ResultSection(
                title: 'Reuse ideas',
                icon: Icons.lightbulb_outline,
                items: reuseIdeas,
              ),
              ResultSection(
                title: 'Eco facts',
                icon: Icons.info_outline,
                items: ecoFacts,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultHeaderCard extends StatelessWidget {
  final ScanResult result;
  const _ResultHeaderCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.greenAccent.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Hero(
              tag: _heroTagFromResult(result),
              child: _ResultImageWidget(result: result),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(result.type, style: const TextStyle(fontSize: 12)),
                Text(
                  'Accuracy: ${(result.accuracy * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultImageWidget extends StatelessWidget {
  final ScanResult result;
  const _ResultImageWidget({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.imageBytes != null) {
      return Image.memory(
        result.imageBytes!,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }
    if (result.imageUrl.isNotEmpty) {
      return Image.network(
        result.imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
    width: 70,
    height: 70,
    color: Colors.grey.shade300,
    child: const Icon(Icons.image_not_supported),
  );
}

String _heroTagFromResult(ScanResult r) {
  final bytes = r.imageBytes;
  if (bytes != null && bytes.isNotEmpty) {
    final l = bytes.length;
    final a = bytes.first;
    final b = bytes.last;
    return 'hero_${l}_${a}_${b}';
  }
  if (r.imageUrl.isNotEmpty) return 'hero_url_${r.imageUrl}';
  return 'hero_${r.name}';
}

List<String> _ecoTipsFallback(ScanResult r) {
  return [
    'Separate ${r.name.isEmpty ? 'this item' : r.name} from other waste to simplify recycling.',
    'Rinse before recycling to maintain material quality.',
    r.isOrganic
        ? 'Organic leftovers can be composted instead of discarded.'
        : 'Reduce single-use items by choosing durable alternatives.',
  ];
}

List<String> _reuseIdeasFallback(ScanResult r) {
  return [
    'Use ${r.name.isEmpty ? 'the item' : r.name} as a small storage container.',
    'Repurpose into crafts or home decor.',
    'Combine multiple pieces for creative DIY projects.',
  ];
}

List<String> _ecoFactsFallback(ScanResult r) {
  return [
    '${r.name.isEmpty ? 'This material' : r.name} reduces waste when recycled properly.',
    'Recycling saves energy compared to producing new materials.',
    'Sorting at the source increases recycling success rates.',
  ];
}
