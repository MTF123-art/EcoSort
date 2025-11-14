import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class GeminiClient {
  final Dio _dio;
  final String apiKey;
  final String baseUrl;

  GeminiClient(
    this._dio, {
    required this.apiKey,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
  });

  static const model = 'gemini-2.5-flash';

  Future<Map<String, dynamic>> classifyWaste(Uint8List imageBytes) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception(
        'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    }

    if (apiKey.isEmpty) throw StateError('GEMINI_API_KEY kosong. Set di .env');

    final mime = _detectMime(imageBytes);
    final b64 = base64Encode(imageBytes);
    const prompt = '''
    Berikan jawaban berupa ONLY valid JSON (tanpa teks tambahan) yang cocok dengan schema:
    {
      "rawLabel": "string (1–3 kata)",
      "score": number (0.0–1.0),
      "isOrganic": boolean,
      "category": "organic" | "plastic" | "paper" | "glass" | "metal" | "other",
      "ecoTips": ["string", ...] (2–3 item),
      "reuseIdeas": ["string", ...] (2–3 item),
      "ecoFacts": ["string", ...] (2–3 item)
    }

    Aturan:
    - rawLabel: 1–3 kata yang mendeskripsikan objek.
    - score: angka antara 0 dan 1 (float) menunjukkan keyakinan.
    - isOrganic: true jika klasifikasi organik; jika true maka category harus "organic".
    - Jika isOrganic false, category harus salah satu dari: "plastic", "paper", "glass", "metal", "other".
    - ecoTips, reuseIdeas, ecoFacts: masing-masing 2–3 kalimat/fragmen singkat.
    - Jangan tambahkan komentar, penjelasan, markdown, atau pembungkus kode. Keluarkan tepat satu objek JSON yang valid sesuai schema di atas.
    Jawab berdasarkan gambar/deskripsi yang diberikan.
    ''';

    final payload = {
      'contents': [
        {
          'parts': [
            {
              'inline_data': {'mime_type': mime, 'data': b64},
            },
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 2048,
        'responseMimeType': 'application/json',
        'responseJsonSchema': {
          'type': 'object',
          'properties': {
            'rawLabel': {
              'type': 'string',
              'description':
                  'The raw label or text input detected from the user, describing the waste item.',
            },
            'score': {
              'type': 'number',
              'minimum': 0,
              'maximum': 1,
              'description':
                  'Confidence score between 0 and 1 reflecting how certain the model is about the classification.',
            },
            'isOrganic': {
              'type': 'boolean',
              'description':
                  'Indicates whether the waste item is classified as organic material.',
            },
            'category': {
              'type': 'string',
              'enum': [
                'organic',
                'plastic',
                'paper',
                'glass',
                'metal',
                'other',
              ],
              'description': 'The classification category for the waste item.',
            },
            'ecoTips': {
              'type': 'array',
              'items': {'type': 'string'},
              'description':
                  'A list of eco-friendly tips related to proper disposal or handling of the item.',
            },
            'reuseIdeas': {
              'type': 'array',
              'items': {'type': 'string'},
              'description':
                  'Creative suggestions for reusing the waste item to reduce environmental impact.',
            },
            'ecoFacts': {
              'type': 'array',
              'items': {'type': 'string'},
              'description':
                  'Interesting environmental facts related to the item or its material.',
            },
          },
          'required': ['rawLabel', 'score', 'isOrganic', 'category'],
        },
      },
    };

    Map<String, dynamic>? data;
    DioException? lastError;
    try {
      final res = await _dio.post(
        '$baseUrl/models/$model:generateContent',
        queryParameters: {},
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
        ),
      );
      data = res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      lastError = e;
      if (e.response?.statusCode != 404) rethrow; // selain 404: hentikan
    }
    if (data == null) {
      throw lastError ?? Exception('Tidak ada respons dari Gemini');
    }

    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Candidates kosong dari Gemini');
    }
    final first = candidates.first as Map<String, dynamic>;
    final content = first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List? ?? const [];

    // Gabungkan semua part bertipe text (beberapa respons membagi output JSON)
    final buffer = StringBuffer();
    for (final p in parts) {
      if (p is Map && p['text'] is String) {
        buffer.writeln(p['text'] as String);
      }
    }
    String text = buffer.toString();
    if (text.isEmpty) throw Exception('Teks respons kosong');
    text = text.trim();
    if (text.startsWith('```')) {
      text = text.replaceAll(RegExp('```(json)?'), '').trim();
    }

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      // Ekstrak blok JSON seimbang jika ada teks tambahan
      final extracted = _extractJsonObject(text) ?? _extractJsonArray(text);
      if (extracted != null) {
        parsed = jsonDecode(extracted) as Map<String, dynamic>;
      } else {
        throw Exception('Gagal parse JSON: $text');
      }
    }

    final rawLabel = (parsed['rawLabel'] ?? 'unknown').toString();
    final score = (parsed['score'] is num)
        ? (parsed['score'] as num).toDouble()
        : 0.0;
    final isOrganic = parsed['isOrganic'] == true;
    final category = (parsed['category'] ?? 'other').toString();
    List<String> _arr(dynamic v) => v is List
        ? v.whereType<dynamic>().map((e) => e.toString()).toList()
        : <String>[];
    final ecoTips = _arr(parsed['ecoTips']);
    final reuseIdeas = _arr(parsed['reuseIdeas']);
    final ecoFacts = _arr(parsed['ecoFacts']);

    return {
      'rawLabel': rawLabel,
      'score': score.clamp(0.0, 1.0),
      'isOrganic': isOrganic,
      'category': category,
      'ecoTips': ecoTips,
      'reuseIdeas': reuseIdeas,
      'ecoFacts': ecoFacts,
    };
  }

  // Mencari objek JSON {...} dengan mengabaikan kurung di dalam string
  String? _extractJsonObject(String s) => _extractBalanced(s, '{', '}');

  // Cadangan: array JSON [...] jika objek tidak ditemukan
  String? _extractJsonArray(String s) => _extractBalanced(s, '[', ']');

  String? _extractBalanced(String s, String open, String close) {
    int depth = 0;
    int start = -1;
    bool inString = false;
    bool escape = false;
    String? best;
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (inString) {
        if (escape) {
          escape = false;
        } else if (ch == '\\') {
          escape = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }
      if (ch == '"') {
        inString = true;
        continue;
      }
      if (ch == open) {
        if (depth == 0) start = i;
        depth++;
      } else if (ch == close) {
        if (depth > 0) depth--;
        if (depth == 0 && start != -1) {
          final candidate = s.substring(start, i + 1);
          if (best == null || candidate.length > best.length) {
            best = candidate;
          }
          start = -1;
        }
      }
    }
    return best;
  }

  String _detectMime(Uint8List bytes) {
    if (bytes.length >= 4) {
      // PNG magic number 89 50 4E 47
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'image/png';
      }
      // JPEG FF D8
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
    }
    return 'image/jpeg'; // fallback
  }
}
