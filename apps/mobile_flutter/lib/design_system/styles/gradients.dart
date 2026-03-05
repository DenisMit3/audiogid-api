import 'package:flutter/material.dart';
import 'package:mobile_flutter/design_system/tokens/colors.dart';

/// Gradient presets
class AppGradients {
  static LinearGradient get primaryButton => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.accentPrimary, AppColors.accentGradientEnd],
      );

  static LinearGradient get imageOverlay => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.8),
        ],
        stops: const [0.3, 1.0],
      );

  static LinearGradient get headerOverlay => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.bgPrimary.withOpacity(0.8),
          AppColors.bgPrimary.withOpacity(0.4),
        ],
      );

  static LinearGradient get disabled => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.textTertiary,
          AppColors.textMuted,
        ],
      );
}


