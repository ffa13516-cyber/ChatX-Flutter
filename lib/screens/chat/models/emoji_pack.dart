import 'emoji_model.dart';

class EmojiPack {
  final String id;
  final String name;
  final String? iconPath;
  final List<EmojiModel> emojis;

  final bool isLocal;
  final String? source;

  EmojiPack({
    required this.id,
    required this.name,
    required this.emojis,
    this.iconPath,
    this.isLocal = true,
    this.source,
  });

  factory EmojiPack.fromJson(Map<String, dynamic> json) {
    return EmojiPack(
      id: json['id'],
      name: json['name'],
      iconPath: json['iconPath'],
      isLocal: json['isLocal'] ?? true,
      source: json['source'],
      emojis: (json['emojis'] as List)
          .map((e) => EmojiModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'isLocal': isLocal,
      'source': source,
      'emojis': emojis.map((e) => e.toJson()).toList(),
    };
  }

  EmojiPack copyWith({
    String? id,
    String? name,
    String? iconPath,
    List<EmojiModel>? emojis,
    bool? isLocal,
    String? source,
  }) {
    return EmojiPack(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      emojis: emojis ?? this.emojis,
      isLocal: isLocal ?? this.isLocal,
      source: source ?? this.source,
    );
  }
}
