import 'dart:typed_data';

class ScanResult {
  final String name; // Nama material terdeteksi
  final String category; // Kategori broad (plastic, organic, metal)
  final String type; // Label spesifik (Non-Organic Waste)
  final double accuracy; // 0..1 probabilitas
  final bool isOrganic; // true jika organik
  final String rawLabel; // label mentah dari model AI
  final String description; // ringkasan edukatif
  final String imageUrl; // sumber gambar (preview URL, bisa kosong)
  final Uint8List? imageBytes; // bytes gambar lokal hasil scan
  final List<String> ecoTips; // saran dari AI
  final List<String> reuseIdeas; // ide reuse dari AI
  final List<String> ecoFacts; // fakta lingkungan dari AI

  const ScanResult({
    required this.name,
    required this.category,
    required this.type,
    required this.accuracy,
    required this.isOrganic,
    required this.rawLabel,
    required this.description,
    required this.imageUrl,
    this.imageBytes,
    this.ecoTips = const [],
    this.reuseIdeas = const [],
    this.ecoFacts = const [],
  });

  ScanResult copyWith({
    String? name,
    String? category,
    String? type,
    double? accuracy,
    bool? isOrganic,
    String? rawLabel,
    String? description,
    String? imageUrl,
    Uint8List? imageBytes,
    List<String>? ecoTips,
    List<String>? reuseIdeas,
    List<String>? ecoFacts,
  }) {
    return ScanResult(
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      accuracy: accuracy ?? this.accuracy,
      isOrganic: isOrganic ?? this.isOrganic,
      rawLabel: rawLabel ?? this.rawLabel,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      ecoTips: ecoTips ?? this.ecoTips,
      reuseIdeas: reuseIdeas ?? this.reuseIdeas,
      ecoFacts: ecoFacts ?? this.ecoFacts,
    );
  }
}
