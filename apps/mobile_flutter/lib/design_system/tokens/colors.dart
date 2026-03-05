import 'dart:ui';

/// Design system colors (dark-focused, with light support)
class AppColors {
  // Background colors
  static const Color bgPrimary = Color(0xFF0F0F12);
  static const Color bgSecondary = Color(0xFF1A1A1F);

  // Glass morphism
  static const Color glassBg = Color(0xCC1C1C20); // 80% opacity
  static const Color glassBorder = Color(0x14FFFFFF); // 8% white

  // Accent colors
  static const Color accentPrimary = Color(0xFF10B981); // Emerald green
  static const Color accentSecondary = Color(0xFF3B82F6); // Blue
  static const Color accentGradientEnd = Color(0xFF059669); // Darker emerald

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textMuted = Color(0xFF52525B);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);

  // Legacy support (mapped to new colors)
  static const Color primaryPurple = accentPrimary;
  static const Color primaryBlue = accentSecondary;
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = bgPrimary;
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = bgSecondary;
}


