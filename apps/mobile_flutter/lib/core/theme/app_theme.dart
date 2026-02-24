import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App colors following a calm, premium audio guide aesthetic
class AppColors {
  // Primary brand colors
  static const Color primaryPurple = Color(0xFF6750A4);
  static const Color primaryBlue = Color(0xFF3B82F6);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);

  // Neutral colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
}

/// Responsive breakpoints
class Breakpoints {
  static const double smallPhone = 320;
  static const double phone = 375;
  static const double largePhone = 414;
  static const double tablet = 768;
  static const double largeTablet = 1024;
}

/// Responsive extension for MediaQuery
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get textScaleFactor => MediaQuery.of(this).textScaler.scale(1.0);
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  bool get isSmallPhone => screenWidth < Breakpoints.phone;
  bool get isPhone =>
      screenWidth >= Breakpoints.phone && screenWidth < Breakpoints.tablet;
  bool get isTablet => screenWidth >= Breakpoints.tablet;
  bool get isLargeTablet => screenWidth >= Breakpoints.largeTablet;
  bool get isLandscape => screenWidth > screenHeight;

  /// Get responsive value based on screen size
  T responsive<T>({
    required T phone,
    T? smallPhone,
    T? largePhone,
    T? tablet,
    T? largeTablet,
  }) {
    if (isLargeTablet && largeTablet != null) return largeTablet;
    if (isTablet && tablet != null) return tablet;
    if (isSmallPhone && smallPhone != null) return smallPhone;
    if (screenWidth >= Breakpoints.largePhone && largePhone != null)
      return largePhone;
    return phone;
  }

  /// Get responsive padding based on screen size
  double get horizontalPadding => responsive(
        smallPhone: 12.0,
        phone: 16.0,
        largePhone: 20.0,
        tablet: 32.0,
        largeTablet: 48.0,
      );

  /// Get responsive card padding
  double get cardPadding => responsive(
        smallPhone: 12.0,
        phone: 16.0,
        tablet: 20.0,
      );
}

/// Spacing constants following 8-point grid
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Duration constants for animations
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration pageTransition = Duration(milliseconds: 350);
}

/// Curves for animations
class AppCurves {
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve bounce = Curves.elasticOut;
}

class AppTheme {
  /// Creates responsive text theme that adapts to font scaling
  static TextTheme _createTextTheme(ColorScheme colorScheme,
      {bool isDark = false}) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: textColor,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
        height: 1.22,
      ),
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.33,
      ),
      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textColor,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.43,
      ),
      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: secondaryTextColor,
        height: 1.33,
      ),
      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryTextColor,
        height: 1.45,
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.light,
      surface: AppColors.surfaceLight,
      background: AppColors.backgroundLight,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _createTextTheme(colorScheme),
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar customization
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card customization
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // Button customizations
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Navigation bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _createTextTheme(colorScheme, isDark: true),
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar customization
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card customization
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: AppColors.surfaceDark,
      ),

      // Button customizations
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Navigation bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.inverseSurface,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.surfaceDark,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
