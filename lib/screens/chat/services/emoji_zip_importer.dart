import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/emoji_model.dart'; 

class EmojiZipImporter {
  static Future<Map<String, dynamic>> processZipArchive(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    Map<String, dynamic>? config;
    final Map<String, Uint8List> imageMap = {};

    for (final file in archive) {
      if (file.isFile) {
        if (file.name.endsWith('.json')) {
          config = jsonDecode(utf8.decode(file.content as List<int>));
        } else if (_isValidImage(file.name)) {
          imageMap[file.name] = Uint8List.fromList(file.content as List<int>);
        }
      }
    }

    if (config == null) throw Exception('Invalid Pack: Missing JSON configuration');

    return {
      'metadata': config,
      'images': imageMap,
    };
  }

  static bool _isValidImage(String name) {
    final path = name.toLowerCase();
    return path.endsWith('.png') || 
           path.endsWith('.webp') || 
           path.endsWith('.svg') || 
           path.endsWith('.lottie');
  }

  static Future<List<ChatXMedia>> convertToMediaList(
    Map<String, dynamic> zipData, 
    String packId
  ) async {
    final List items = zipData['metadata']['items'] ?? [];
    final Map<String, Uint8List> images = zipData['images'];

    return items.map((item) {
      final fileName = item['file'];
      return ChatXMedia(
        id: item['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        packId: packId,
        url: '', 
        type: _determineType(fileName),
        label: item['label'],
        isAnimated: fileName.endsWith('.lottie'),
        metadata: {
          'raw_bytes': images[fileName],
          'original_name': fileName,
        },
      );
    }).toList();
  }

  static MediaType _determineType(String fileName) {
    if (fileName.endsWith('.svg')) return MediaType.svg;
    if (fileName.endsWith('.lottie')) return MediaType.lottie;
    if (fileName.contains('sticker')) return MediaType.sticker;
    return MediaType.emoji;
  }
}
