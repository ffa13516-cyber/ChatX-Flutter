import '../models/sticker_model.dart';

class StickerService {
  // 🔥 Singleton
  static final StickerService _instance = StickerService._internal();
  factory StickerService() => _instance;
  StickerService._internal();

  // 🔥 Packs
  final List<StickerPack> _packs = [
    StickerPack(
      id: "default",
      name: "Default",
      stickers: [
        StickerModel(
          id: "1",
          path: "assets/stickers/1.png",
        ),
        StickerModel(
          id: "2",
          path: "assets/stickers/2.png",
        ),
        StickerModel(
          id: "3",
          path: "assets/stickers/3.png",
        ),
      ],
    ),
  ];

  List<StickerPack> get packs => _packs;

  // 🔥 كل الاستيكرز (لو احتجتهم)
  List<StickerModel> get allStickers =>
      _packs.expand((p) => p.stickers).toList();

  // 🔥 إضافة Pack جديد
  void addPack(StickerPack pack) {
    _packs.add(pack);
  }
}
