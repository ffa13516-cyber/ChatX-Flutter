class EmojiModel {
  final String id;
  final String code;
  final String? assetPath;
  final String? char;
  final String? packId;
  final String? name;
  final List<String>? keywords;

  EmojiModel({
    required this.id,
    required this.code,
    this.assetPath,
    this.char,
    this.packId,
    this.name,
    this.keywords,
  }) : assert(
          assetPath != null || char != null,
        );

  bool get isCustom => assetPath != null;

  String get displayValue => char ?? '';

  factory EmojiModel.fromJson(Map<String, dynamic> json) {
    return EmojiModel(
      id: json['id'],
      code: json['code'],
      assetPath: json['assetPath'],
      char: json['char'],
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
      'code': code,
      'assetPath': assetPath,
      'char': char,
      'packId': packId,
      'name': name,
      'keywords': keywords,
    };
  }

  EmojiModel copyWith({
    String? id,
    String? code,
    String? assetPath,
    String? char,
    String? packId,
    String? name,
    List<String>? keywords,
  }) {
    return EmojiModel(
      id: id ?? this.id,
      code: code ?? this.code,
      assetPath: assetPath ?? this.assetPath,
      char: char ?? this.char,
      packId: packId ?? this.packId,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
    );
  }
}
