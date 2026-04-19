import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00B4D8);
  static const Color primaryDark = Color(0xFF0096C7);
  static const Color primaryLight = Color(0xFF48CAE4);
  static const Color accent = Color(0xFFFF6B9D);
  static const Color bgDark = Color(0xFF0D0D1A);
  static const Color bgSurface = Color(0xFF12122A);
  static const Color bgElevated = Color(0xFF1A1A35);
  static const Color bgCard = Color(0xFF1E1E3A);
  static const Color bgInput = Color(0xFF1A1A35);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFF616161);
  static const Color online = Color(0xFF00E676);
  static const Color unreadBadge = Color(0xFFFF6B9D);
  static const Color divider = Color(0xFF1E1E3A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00B4D8), Color(0xFF0096C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF12122A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const List<Color> avatarColors = [
    Color(0xFF7B68EE),
    Color(0xFF00B4D8),
    Color(0xFF2196F3),
    Color(0xFFFF6B9D),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
  ];

  static Color avatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    return avatarColors[name.codeUnitAt(0) % avatarColors.length];
  }
}
