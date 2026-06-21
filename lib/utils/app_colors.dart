import 'package:flutter/material.dart';

class AppColors {
  // 1. Primary & Brand Colors
  // الـ iOS Blue الأيقوني، مشع وبيدي طابع ذكي ونظيف للواجهة
  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryDark = Color(0xFF0056B3);
  static const Color primaryLight = Color(0xFF5AC8FA);
  
  // لون التنبيهات والـ Pop Elements من أبل لتميز بصري عالي
  static const Color accent = Color(0xFFFF375F);

  // 2. Backgrounds & Surfaces (OLED Focus)
  // خلفية الشاشة الأساسية - سوداء مطلقة لعمق الـ OLED
  static const Color bgDark = Color(0xFF000000); // <-- استخدم ده للـ Scaffold Background
  
  // خلفية الـ Bottom Nav أو الـ App Bar 
  static const Color bgSurface = Color(0xFF09090B);
  
  // خلفية الكروت أو العناصر الطافية (Elevated)
  static const Color bgElevated = Color(0xFF121214);
  
  // **التعديل هنا:** إعادة إضافة لون bgCard لحل مشكلة الـ Build
  static const Color bgCard = Color(0xFF1C1C1E);
  
  // خلفية حقل البحث (Search Bar)
  static const Color bgInput = Color(0xFF1C1C1E);

  // 3. Typography (Texts)
  // درجات النصوص المعتمدة لراحة العين أثناء القراءة
  static const Color textPrimary = Color(0xFFF5F5F7); // لأسماء المستخدمين
  static const Color textSecondary = Color(0xFF8E8E93); // للرسائل والوقت
  static const Color textHint = Color(0xFF48484A); // للـ Placeholder في البحث

  // 4. Status & Indicators
  // الأخضر الحيوي لحالة النشاط الدقيق (Online)
  static const Color online = Color(0xFF30D158);
  
  // لون فقاعة عدد الرسائل غير المقروءة (Badge)
  static const Color unreadBadge = Color(0xFFFF375F);
  
  // لون الفواصل بين المحادثات
  static const Color divider = Color(0xFF1C1C1E);

  // 5. Gradients
  // تدرج أزرق ديناميكي للزراير الأساسية
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF2F66FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // تدرج الخلفية المظلمة العميقة
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF09090B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 6. Dynamic Avatar Colors (iOS Vibrant Palette)
  static const List<Color> avatarColors = [
    Color(0xFF5E5CE6), // iOS Purple
    Color(0xFF0A84FF), // iOS Blue
    Color(0xFF64D2FF), // iOS Sky
    Color(0xFFFF375F), // iOS Pink
    Color(0xFFFF9F0A), // iOS Orange
    Color(0xFF30D158), // iOS Green
    Color(0xFF5856D6), // iOS Indigo (Fixed Valid Hex)
  ];

  // دالة ذكية لإعطاء كل مستخدم لون ثابت بناءً على اسمه
  static Color avatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    // بناخد أول حرف ونحوله لرقم، ونجيب باقي القسمة على عدد الألوان
    return avatarColors[name.codeUnitAt(0) % avatarColors.length];
  }
}
