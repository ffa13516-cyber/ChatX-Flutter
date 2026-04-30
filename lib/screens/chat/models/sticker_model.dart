class StickerModel {
  final String id;

  /// مسار الصورة (ممكن يكون asset أو file بعد فك الـ ZIP)
  final String path;

  /// الباك اللي تابع ليه
  final String packId;

  StickerModel({
    required this.id,
    required this.path,
    required this.packId,
  });

  // 🔥 من JSON (مهم للـ ZIP import)
  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      id: json['id'],
      path: json['path'],
      packId: json['packId'],
    );
  }

  // 🔥 إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'packId': packId,
    };
  }
}
