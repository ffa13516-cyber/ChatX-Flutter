import '../models/emoji_model.dart';

class EmojiService {
  /// 🔥 Singleton
  static final EmojiService _instance = EmojiService._internal();
  factory EmojiService() => _instance;
  EmojiService._internal();

  /// 🔹 مصدر البيانات (مؤقت - بعدين JSON / API)
  final List<EmojiModel> _emojis = [
    EmojiModel(id: '1', code: ':smile:', char: '😄'),
    EmojiModel(id: '2', code: ':laugh:', char: '😂'),
    EmojiModel(id: '3', code: ':heart:', char: '❤️'),

    // Custom
    EmojiModel(
      id: '4',
      code: ':fire_custom:',
      assetPath: 'assets/emojis/fire.png',
    ),
  ];

  /// 🔥 Cache للـ map (مهم جدًا للأداء)
  Map<String, EmojiModel>? _emojiMapCache;

  Map<String, EmojiModel> get emojiMap {
    if (_emojiMapCache != null) return _emojiMapCache!;

    final map = <String, EmojiModel>{};
    for (var e in _emojis) {
      map[e.code] = e;
    }

    _emojiMapCache = map;
    return map;
  }

  /// 🔥 get by code (مهم للـ parser)
  EmojiModel? getByCode(String code) {
    return emojiMap[code];
  }

  /// 🔥 كل الإيموجي (UI)
  List<EmojiModel> get allEmojis => _emojis;

  /// 🔥 إضافة Emoji جديد (مثلاً من pack)
  void addEmoji(EmojiModel emoji) {
    _emojis.add(emoji);

    // 🧠 reset cache
    _emojiMapCache = null;
  }

  // ===============================
  // 🔥🔥🔥 RECENT EMOJIS SYSTEM
  // ===============================

  final List<String> _recentCodes = [];
  static const int _maxRecent = 24;

  /// 📌 سجل استخدام emoji
  void registerUsage(EmojiModel emoji) {
    _recentCodes.remove(emoji.code); // شيله لو موجود
    _recentCodes.insert(0, emoji.code); // حطه في الأول

    if (_recentCodes.length > _maxRecent) {
      _recentCodes.removeLast();
    }
  }

  /// 📌 رجّع recent emojis
  List<EmojiModel> getRecentEmojis() {
    return _recentCodes
        .map((code) => emojiMap[code])
        .whereType<EmojiModel>()
        .toList();
  }

  /// 📌 clear (لو عايز reset)
  void clearRecent() {
    _recentCodes.clear();
  }
}
