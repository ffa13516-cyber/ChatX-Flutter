import 'emoji_model.dart';

class EmojiPackDTO {
  final String name;
  final List<EmojiModel> emojis;

  EmojiPackDTO({
    required this.name,
    required this.emojis,
  });

  /// 🔥 من JSON (جاي من ZIP)
  factory EmojiPackDTO.fromJson(Map<String, dynamic> json) {
    final list = (json['emojis'] as List)
        .map((e) => EmojiModel(
              id: e['id'],
              code: e['code'],
              char: e['char'],
              assetPath: e['asset'],
            ))
        .toList();

    return EmojiPackDTO(
      name: json['name'],
      emojis: list,
    );
  }
}
