import 'sticker_model.dart';

class PackModel {
  final String id;

  /// اسم الباك (مثال: Memes)
  final String name;

  /// صورة الباك (thumbnail)
  final String? thumbnail;

  /// كل الاستيكرات اللي جواه
  final List<StickerModel> stickers;

  PackModel({
    required this.id,
    required this.name,
    this.thumbnail,
    required this.stickers,
  });

  // 🔥 من JSON (مهم للـ ZIP)
  factory PackModel.fromJson(Map<String, dynamic> json) {
    return PackModel(
      id: json['id'],
      name: json['name'],
      thumbnail: json['thumbnail'],
      stickers: (json['stickers'] as List)
          .map((e) => StickerModel.fromJson(e))
          .toList(),
    );
  }

  // 🔥 إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'stickers': stickers.map((e) => e.toJson()).toList(),
    };
  }
}
