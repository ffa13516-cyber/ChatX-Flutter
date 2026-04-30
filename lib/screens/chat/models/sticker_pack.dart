import 'sticker_model.dart';

class StickerPack {
  final String id;
  final String name;
  final List<StickerModel> stickers;

  StickerPack({
    required this.id,
    required this.name,
    required this.stickers,
  });
}
