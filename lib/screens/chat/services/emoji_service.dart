import '../models/emoji_model.dart';

class EmojiService {
  // 🔥 Singleton (عشان يبقى instance واحد بس)
  static final EmojiService _instance = EmojiService._internal();

  factory EmojiService() => _instance;

  EmojiService._internal();

  // 🔥 قائمة الإيموجي (ممكن تيجي من JSON بعدين)
  final List<EmojiModel> _emojis = [
    // 🔹 Unicode Emojis
    EmojiModel(id: '1', code: ':smile:', char: '😄'),
    EmojiModel(id: '2', code: ':laugh:', char: '😂'),
    EmojiModel(id: '3', code: ':heart:', char: '❤️'),

    // 🔹 Custom Emojis (مثال)
    EmojiModel(
      id: '4',
      code: ':fire_custom:',
      assetPath: 'assets/emojis/fire.png',
    ),
  ];

  // 🔥 Map مهم للـ parser
  Map<String, EmojiModel> get emojiMap {
    final map = <String, EmojiModel>{};
    for (var e in _emojis) {
      map[e.code] = e;
    }
    return map;
  }

  // 🔥 للإستخدام في UI
  List<EmojiModel> get allEmojis => _emojis;

  // 🔥 إضافة emoji جديد (مهم للـ packs بعدين)
  void addEmoji(EmojiModel emoji) {
    _emojis.add(emoji);
  }
}
