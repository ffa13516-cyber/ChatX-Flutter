import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';

import '../models/emoji_model.dart';
import '../models/emoji_pack.dart';

class EmojiZipImporter {
  Future<EmojiPack> importFromBytes(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);

    Map<String, dynamic>? jsonData;
    final Map<String, Uint8List> images = {};

    for (final file in archive) {
      if (file.isFile) {
        final name = file.name;

        if (name.endsWith('.json')) {
          final content = utf8.decode(file.content as List<int>);
          jsonData = jsonDecode(content);
        } else if (_isImage(name)) {
          images[name] = Uint8List.fromList(file.content as List<int>);
        }
      }
    }

    if (jsonData == null) {
      throw Exception('No JSON file found in ZIP');
    }

    final packId = jsonData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    final List emojisJson = jsonData['emojis'];

    final emojis = emojisJson.map<EmojiModel>((e) {
      final fileName = e['file'];

      return EmojiModel(
        id: e['id'],
        code: e['code'],
        assetPath: fileName,
        packId: packId,
        name: e['name'],
        keywords: e['keywords'] != null
            ? List<String>.from(e['keywords'])
            : null,
      );
    }).toList();

    return EmojiPack(
      id: packId,
      name: jsonData['name'] ?? 'Imported Pack',
      iconPath: jsonData['icon'],
      emojis: emojis,
      isLocal: true,
      source: 'zip',
    );
  }

  bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }
}
