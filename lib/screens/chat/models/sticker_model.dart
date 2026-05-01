class StickerModel {
  final String id;
  final String assetPath;
  final String? packId;
  final String? name;
  final List<String>? keywords;

  StickerModel({
    required this.id,
    required this.assetPath,
    this.packId,
    this.name,
    this.keywords,
  });

  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      id: json['id'],
      assetPath: json['assetPath'],
      packId: json['packId'],
      name: json['name'],
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetPath': assetPath,
      'packId': packId,
      'name': name,
      'keywords': keywords,
    };
  }

  StickerModel copyWith({
    String? id,
    String? assetPath,
    String? packId,
    String? name,
    List<String>? keywords,
  }) {
    return StickerModel(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      packId: packId ?? this.packId,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
    );
  }
}
