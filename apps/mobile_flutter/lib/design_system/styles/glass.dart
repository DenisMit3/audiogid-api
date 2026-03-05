import 'package:flutter/material.dart';
import 'package:mobile_flutter/design_system/tokens/colors.dart';
import 'package:mobile_flutter/design_system/tokens/elevation.dart';
import 'package:mobile_flutter/design_system/tokens/radius.dart';

/// Glass morphism decoration helpers
class GlassDecoration {
  static BoxDecoration container({
    double borderRadius = AppRadius.md,
    bool showBorder = true,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: AppColors.glassBg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder
          ? Border.all(
              color: AppColors.glassBorder,
              width: 1,
            )
          : null,
      boxShadow: showShadow ? AppShadows.glass : null,
    );
  }

  static BoxDecoration card({
    double borderRadius = AppRadius.card,
  }) {
    return BoxDecoration(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
      boxShadow: AppShadows.card,
    );
  }

  static BoxDecoration bottomSheet() {
    return BoxDecoration(
      color: AppColors.glassBg,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.bottomSheet),
      ),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
      boxShadow: AppShadows.glass,
    );
  }
}


