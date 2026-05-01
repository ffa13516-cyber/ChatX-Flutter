import 'dart:typed_data';

import '../models/emoji_model.dart';
import '../models/emoji_pack.dart';
import '../models/emoji_pack_dto.dart';
import 'emoji_zip_importer.dart';

class EmojiService {
  /// 🔥 Singleton
  static final EmojiService _instance = EmojiService._internal();
  factory EmojiService() => _instance;
  EmojiService._internal();

  /// 🔥 Packs بدل ليست واحدة
  final List<EmojiPack> _packs = [
    EmojiPack(
      name: "Default",
      emojis: [
        EmojiModel(id: '1', code: ':smile:', char: '😄'),
        EmojiModel(id: '2', code: ':laugh:', char: '😂'),
        EmojiModel(id: '3', code: ':heart:', char: '❤️'),
      ],
    ),

    /// 🔹 Custom Pack
    EmojiPack(
      name: "Custom",
      emojis: [
        EmojiModel(
          id: '4',
          code: ':fire_custom:',
          assetPath: 'assets/emojis/fire.png',
        ),
      ],
    ),
  ];

  /// 🔥 Cache للـ map
  Map<String, EmojiModel>? _emojiMapCache;

  Map<String, EmojiModel> get emojiMap {
    if (_emojiMapCache != null) return _emojiMapCache!;

    final map = <String, EmojiModel>{};

    for (var pack in _packs) {
      for (var e in pack.emojis) {
        map[e.code] = e;
      }
    }

    _emojiMapCache = map;
    return map;
  }

  /// 🔥 get by code
  EmojiModel? getByCode(String code) {
    return emojiMap[code];
  }

  /// 🔥 كل الإيموجي (UI)
  List<EmojiModel> get allEmojis {
    return _packs.expand((p) => p.emojis).toList();
  }

  /// 🔥 رجّع الـ packs
  List<EmojiPack> get packs => _packs;

  /// 🔥 إضافة Emoji جديد (قديم)
  void addEmoji(EmojiModel emoji) {
    _packs.first.emojis.add(emoji);
    _emojiMapCache = null;
  }

  /// 🔥 إضافة Pack كامل
  void addPack(EmojiPack pack) {
    _packs.add(pack);
    _emojiMapCache = null;
  }

  // =====================================
  // 🔥🔥🔥 NEW: ADD EMOJI FROM IMAGE
  // =====================================

  int _customIdCounter = 1000;

  Future<EmojiModel> addCustomEmojiFromBytes(Uint8List bytes) async {
    /// 🔥 نلاقي الـ Custom pack
    final customPack = _packs.firstWhere(
      (p) => p.name == "Custom",
      orElse: () {
        final newPack = EmojiPack(name: "Custom", emojis: []);
        _packs.add(newPack);
        return newPack;
      },
    );

    final id = (_customIdCounter++).toString();
    final code = ':custom_$id:';

    /// ❗ حالياً مفيش تخزين فعلي → هنخزن bytes مؤقت (هنتطور بعدين)
    final emoji = EmojiModel(
      id: id,
      code: code,
      bytes: bytes, // 🔥 مهم
      isCustom: true,
    );

    customPack.emojis.add(emoji);

    /// 🔥 reset cache
    _emojiMapCache = null;

    return emoji;
  }

  // =====================================
  // 🔥🔥🔥 ZIP IMPORT
  // =====================================

  Future<bool> importFromZip(Uint8List bytes) async {
    final dto = await EmojiZipImporter.import(bytes);

    if (dto == null) return false;

    final pack = EmojiPack(
      name: dto.name,
      emojis: dto.emojis,
    );

    addPack(pack);

    return true;
  }

  // ===============================
  // 🔥🔥🔥 RECENT EMOJIS SYSTEM
  // ===============================

  final List<String> _recentCodes = [];
  static const int _maxRecent = 24;

  void registerUsage(EmojiModel emoji) {
    _recentCodes.remove(emoji.code);
    _recentCodes.insert(0, emoji.code);

    if (_recentCodes.length > _maxRecent) {
      _recentCodes.removeLast();
    }
  }

  List<EmojiModel> getRecentEmojis() {
    return _recentCodes
        .map((code) => emojiMap[code])
        .whereType<EmojiModel>()
        .toList();
  }

  void clearRecent() {
    _recentCodes.clear();
  }
}
