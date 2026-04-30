import '../models/sticker_model.dart';
import '../models/sticker_pack.dart'; // 🆕🔥 مهم

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
          packId: "default", // 🆕🔥
          path: "assets/stickers/1.png",
        ),
        StickerModel(
          id: "2",
          packId: "default", // 🆕🔥
          path: "assets/stickers/2.png",
        ),
        StickerModel(
          id: "3",
          packId: "default", // 🆕🔥
          path: "assets/stickers/3.png",
        ),
      ],
    ),
  ];

  List<StickerPack> get packs => _packs;

  // 🔥 كل الاستيكرز
  List<StickerModel> get allStickers =>
      _packs.expand((p) => p.stickers).toList();

  // 🔥 إضافة Pack جديد
  void addPack(StickerPack pack) {
    _packs.add(pack);
  }
}
