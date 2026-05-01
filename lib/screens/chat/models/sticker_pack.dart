import 'sticker_model.dart';

class StickerPack {
  final String id;
  final String name;
  final String? iconPath;
  final List<StickerModel> stickers;

  final bool isLocal;
  final String? source;

  StickerPack({
    required this.id,
    required this.name,
    required this.stickers,
    this.iconPath,
    this.isLocal = true,
    this.source,
  });

  factory StickerPack.fromJson(Map<String, dynamic> json) {
    return StickerPack(
      id: json['id'],
      name: json['name'],
      iconPath: json['iconPath'],
      isLocal: json['isLocal'] ?? true,
      source: json['source'],
      stickers: (json['stickers'] as List)
          .map((e) => StickerModel.fromJson(e))
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
      'stickers': stickers.map((e) => e.toJson()).toList(),
    };
  }

  StickerPack copyWith({
    String? id,
    String? name,
    String? iconPath,
    List<StickerModel>? stickers,
    bool? isLocal,
    String? source,
  }) {
    return StickerPack(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      stickers: stickers ?? this.stickers,
      isLocal: isLocal ?? this.isLocal,
      source: source ?? this.source,
    );
  }
}
