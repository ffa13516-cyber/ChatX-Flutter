class EmojiModel {
  final String id;

  /// الشكل اللي بيتكتب في الرسالة
  /// مثال: :smile:
  final String code;

  /// الصورة (لو custom emoji)
  final String? assetPath;

  /// لو emoji عادي (😀)
  final String? char;

  EmojiModel({
    required this.id,
    required this.code,
    this.assetPath,
    this.char,
  });

  /// هل ده custom ولا unicode
  bool get isCustom => assetPath != null;

  // 🔥 للتحويل من JSON (مهم للـ packs بعدين)
  factory EmojiModel.fromJson(Map<String, dynamic> json) {
    return EmojiModel(
      id: json['id'],
      code: json['code'],
      assetPath: json['assetPath'],
      char: json['char'],
    );
  }

  // 🔥 للتحويل لـ JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'assetPath': assetPath,
      'char': char,
    };
  }
}
