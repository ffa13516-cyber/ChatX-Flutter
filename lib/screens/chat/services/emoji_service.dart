import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/emoji_model.dart';
import '../models/sticker_pack.dart';
import 'emoji_zip_importer.dart';

class EmojiService extends ChangeNotifier {
  static final EmojiService _instance = EmojiService._internal();
  factory EmojiService() => _instance;
  EmojiService._internal();

  final List<MediaPack> _packs = [];
  final List<String> _recentIds = [];
  Map<String, ChatXMedia> _mediaCache = {};

  List<MediaPack> get packs => List.unmodifiable(_packs);
  
  List<ChatXMedia> get recentMedia => _recentIds
      .map((id) => _mediaCache[id])
      .whereType<ChatXMedia>()
      .toList();

  Future<void> importPackFromZip(Uint8List zipBytes) async {
    try {
      final processedData = await EmojiZipImporter.processZipArchive(zipBytes);
      final packId = processedData['metadata']['id'] ?? DateTime.now().toString();
      
      final mediaItems = await EmojiZipImporter.convertToMediaList(processedData, packId);
      
      final newPack = MediaPack(
        id: packId,
        title: processedData['metadata']['name'] ?? 'Untitled Pack',
        authorId: 'system',
        thumbnail: '',
        items: mediaItems,
        createdAt: DateTime.now(),
      );

      _packs.add(newPack);
      for (var item in mediaItems) {
        _mediaCache[item.id] = item;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Import Error: $e');
    }
  }

  Future<void> addSingleMedia({
    required Uint8List bytes,
    required MediaType type,
    bool removeBackground = false,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newMedia = ChatXMedia(
      id: id,
      packId: 'custom_uploads',
      url: '',
      type: type,
      metadata: {'raw_bytes': bytes, 'bg_removed': removeBackground},
    );

    final customPackIndex = _packs.indexWhere((p) => p.id == 'custom_uploads');
    if (customPackIndex != -1) {
      _packs[customPackIndex].items.add(newMedia);
    } else {
      _packs.add(MediaPack(
        id: 'custom_uploads',
        title: 'Custom',
        authorId: 'user',
        thumbnail: '',
        items: [newMedia],
        createdAt: DateTime.now(),
      ));
    }

    _mediaCache[id] = newMedia;
    notifyListeners();
  }

  void recordUsage(String mediaId) {
    _recentIds.remove(mediaId);
    _recentIds.insert(0, mediaId);
    if (_recentIds.length > 30) _recentIds.removeLast();
    notifyListeners();
  }

  ChatXMedia? findMediaById(String id) => _mediaCache[id];
}
