import 'package:flutter/material.dart';

class AppColors {
  // الـ iOS Blue الأيقوني، مشع وبيدي طابع ذكي ونظيف للواجهة
  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryDark = Color(0xFF0056B3);
  static const Color primaryLight = Color(0xFF5AC8FA);
  
  // لون التنبيهات والـ Pop Elements من أبل لتميز بصري عالي
  static const Color accent = Color(0xFFFF375F);
  
  // خلفية سوداء مطلقة لعمق الـ OLED وظهور تأثير الزجاج الشفاف بنقاء 100%
  static const Color bgDark = Color(0xFF000000);
  static const Color bgSurface = Color(0xFF09090B);
  static const Color bgElevated = Color(0xFF121214);
  static const Color bgCard = Color(0xFF1C1C1E);
  static const Color bgInput = Color(0xFF1C1C1E);
  
  // درجات الـ Typography المعتمدة في أبل (Pure & Clean) لراحة العين أثناء القراءة
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textHint = Color(0xFF48484A);
  
  // الأخضر الحيوي لحالة النشاط الدقيق
  static const Color online = Color(0xFF30D158);
  static const Color unreadBadge = Color(0xFFFF375F);
  static const Color divider = Color(0xFF1C1C1E);

  // تدرج أزرق ديناميكي فخم للـ Buttons أو العناصر التفاعلية
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF2F66FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // تدرج الخلفية المظلمة العميقة من الأسود المطلق للرمادي الفاحم
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF09090B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // توزيعة ألوان الأفاتار الرسمية لنظام iOS (Vibrant & Premium)
  static const List<Color> avatarColors = [
    Color(0xFF5E5CE6), // iOS Purple
    Color(0xFF0A84FF), // iOS Blue
    Color(0xFF64D2FF), // iOS Sky
    Color(0xFFFF375F), // iOS Pink
    Color(0xFFFF9F0A), // iOS Orange
    Color(0xFF30D158), // iOS Green
    Color(0xFFBFBF5AF2), // iOS Indigo
  ];

  static Color avatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    return avatarColors[name.codeUnitAt(0) % avatarColors.length];
  }
}
