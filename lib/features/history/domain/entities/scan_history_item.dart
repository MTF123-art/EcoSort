import 'dart:typed_data';

class ScanHistoryItem {
  final int? id;
  final DateTime createdAt;
  final String label;
  final String category;
  final bool isOrganic;
  final double accuracy;
  final String? imagePath;
  final Uint8List? imageBytes;

  const ScanHistoryItem({
    this.id,
    required this.createdAt,
    required this.label,
    required this.category,
    required this.isOrganic,
    required this.accuracy,
    this.imagePath,
    this.imageBytes,
  });

  ScanHistoryItem copyWith({
    int? id,
    DateTime? createdAt,
    String? label,
    String? category,
    bool? isOrganic,
    double? accuracy,
    String? imagePath,
    Uint8List? imageBytes,
  }) {
    return ScanHistoryItem(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      label: label ?? this.label,
      category: category ?? this.category,
      isOrganic: isOrganic ?? this.isOrganic,
      accuracy: accuracy ?? this.accuracy,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

  Map<String, Object?> toMap({String? imageBase64}) => {
    'id': id,
    'created_at': createdAt.millisecondsSinceEpoch,
    'label': label,
    'category': category,
    'is_organic': isOrganic ? 1 : 0,
    'accuracy': accuracy,
    'image_path': imagePath,
    'image_base64': imageBase64,
  };

  static ScanHistoryItem fromMap(Map<String, Object?> map, {Uint8List? bytes}) {
    return ScanHistoryItem(
      id: map['id'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      label: (map['label'] as String?) ?? '-',
      category: (map['category'] as String?) ?? '-',
      isOrganic: ((map['is_organic'] as int?) ?? 0) == 1,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      imagePath: map['image_path'] as String?,
      imageBytes: bytes,
    );
  }
}
