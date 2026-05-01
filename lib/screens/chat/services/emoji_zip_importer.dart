import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/emoji_pack_dto.dart';

class EmojiZipImporter {
  /// 🔥 فك الـ ZIP وتحويله لـ DTO
  static Future<EmojiPackDTO?> import(Uint8List bytes) async {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);

      Map<String, dynamic>? jsonData;

      /// 🔎 دور على ملف JSON
      for (final file in archive) {
        if (file.name.endsWith('.json')) {
          final content = utf8.decode(file.content);
          jsonData = json.decode(content);
          break;
        }
      }

      if (jsonData == null) return null;

      /// 🔥 حوله لـ DTO
      final dto = EmojiPackDTO.fromJson(jsonData);

      return dto;
    } catch (e) {
      print("❌ ZIP IMPORT ERROR: $e");
      return null;
    }
  }
}
