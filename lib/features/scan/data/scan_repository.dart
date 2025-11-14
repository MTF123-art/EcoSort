import 'dart:typed_data';
import '../domain/entities/scan_result.dart';
import 'gemini_client.dart';

class ScanRepository {
  final GeminiClient client;
  ScanRepository(this.client);

  Future<ScanResult> classify(Uint8List imageBytes) async {
    final raw = await client.classifyWaste(imageBytes);
    // Mapping raw response ke entity.
    final rawLabel = raw['rawLabel'] as String;
    final isOrganic = raw['isOrganic'] as bool;
    final score = (raw['score'] as double); // 0..1
    final category = raw['category'] as String;

    // Sederhana: name ambil rawLabel capitalized
    final name = _capitalize(rawLabel);
    final type = isOrganic ? 'Organic Waste' : 'Non-Organic Waste';
    final description = isOrganic
        ? 'This material is biodegradable and can decompose naturally.'
        : 'This material is non-biodegradable and should be recycled properly.';

    final ecoTips =
        (raw['ecoTips'] as List?)?.whereType<String>().toList() ?? const [];
    final reuseIdeas =
        (raw['reuseIdeas'] as List?)?.whereType<String>().toList() ?? const [];
    final ecoFacts =
        (raw['ecoFacts'] as List?)?.whereType<String>().toList() ?? const [];

    return ScanResult(
      name: name,
      category: category,
      type: type,
      accuracy: score,
      isOrganic: isOrganic,
      rawLabel: rawLabel,
      description: description,
      imageUrl: '',
      imageBytes: imageBytes,
      ecoTips: ecoTips,
      reuseIdeas: reuseIdeas,
      ecoFacts: ecoFacts,
    );
  }

  String _capitalize(String v) {
    if (v.isEmpty) return v;
    return v[0].toUpperCase() + v.substring(1);
  }
}
