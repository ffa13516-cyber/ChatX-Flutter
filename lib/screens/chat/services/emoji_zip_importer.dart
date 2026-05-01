import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/emoji_pack_dto.dart';

class EmojiZipImporter {
  /// 🔥 فك الـ ZIP وتحويله لـ DTO + Images
  static Future<EmojiPackDTO?> import(Uint8List bytes) async {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);

      Map<String, dynamic>? jsonData;

      /// 🧠 نخزن كل الملفات
      final Map<String, Uint8List> files = {};

      for (final file in archive) {
        if (file.isFile) {
          files[file.name] = Uint8List.fromList(file.content);
        }
      }

      /// 🔎 دور على JSON
      for (final entry in files.entries) {
        if (entry.key.endsWith('.json')) {
          final content = utf8.decode(entry.value);
          jsonData = json.decode(content);
          break;
        }
      }

      if (jsonData == null) return null;

      /// 🔥 حوله لـ DTO
      final dto = EmojiPackDTO.fromJson(jsonData);

      /// 🔥 اربط الصور بالإيموجي
      for (final emoji in dto.emojis) {
        final fileName = emoji.file; // لازم يكون موجود في DTO

        if (files.containsKey(fileName)) {
          emoji.bytes = files[fileName];
        } else {
          print("⚠️ Missing file: $fileName");
        }
      }

      return dto;
    } catch (e) {
      print("❌ ZIP IMPORT ERROR: $e");
      return null;
    }
  }
}
