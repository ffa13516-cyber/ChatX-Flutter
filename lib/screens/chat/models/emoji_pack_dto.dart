import 'dart:typed_data';

class EmojiPackDTO {
  final String name;
  final List<EmojiDTO> emojis;

  EmojiPackDTO({
    required this.name,
    required this.emojis,
  });

  factory EmojiPackDTO.fromJson(Map<String, dynamic> json) {
    return EmojiPackDTO(
      name: json['name'] ?? '',
      emojis: (json['emojis'] as List)
          .map((e) => EmojiDTO.fromJson(e))
          .toList(),
    );
  }
}

class EmojiDTO {
  final String code;
  final String file;

  /// 🔥 هيتحط بعد فك الـ ZIP
  Uint8List? bytes;

  EmojiDTO({
    required this.code,
    required this.file,
    this.bytes,
  });

  factory EmojiDTO.fromJson(Map<String, dynamic> json) {
    return EmojiDTO(
      code: json['code'] ?? '',
      file: json['file'] ?? '',
    );
  }
}
