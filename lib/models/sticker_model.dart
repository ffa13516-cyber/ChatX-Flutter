import 'package:flutter/foundation.dart';

/// ده الـ Model اللي بيحدد هوية كل ستيكر أو رمز في ChatX.
/// التصميم ده بيدعم الـ Premium والتحكم في الخلفية عشان ننافس تليجرام.

enum StickerType { 
  inline,    // رمز صغير بيظهر وسط الكلام (Emoji)
  standalone // ستيكر كبير بيتبعت لوحده
}

class StickerModel {
  final String id;           // معرف فريد للستيكر
  final String url;          // لينك الصورة على السيرفر (CDN)
  final StickerType type;    // نوع الستيكر (رمز ولا ستيكر)
  final bool isPremium;      // لو مقفول بقفل زي اللي في الصورة
  final bool hasBackground;  // الميزة اللي اليوزر بيتحكم فيها
  final String categoryId;   // تبع أنهي باكيدج (مثلاً: "قطط"، "ضحك")

  StickerModel({
    required this.id,
    required this.url,
    required this.categoryId,
    this.type = StickerType.standalone,
    this.isPremium = false,
    this.hasBackground = true,
  });

  // لتحويل البيانات من Firebase (JSON) لـ Object نقدر نستخدمه في الكود
  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      categoryId: json['categoryId'] ?? 'general',
      type: json['type'] == 'inline' ? StickerType.inline : StickerType.standalone,
      isPremium = json['isPremium'] ?? false,
      hasBackground = json['hasBackground'] ?? true,
    );
  }

  // لتحويل الـ Object لـ JSON عشان نرفعه للسيرفر
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type == StickerType.inline ? 'inline' : 'standalone',
      'isPremium': isPremium,
      'hasBackground': hasBackground,
      'categoryId': categoryId,
    };
  }
}
