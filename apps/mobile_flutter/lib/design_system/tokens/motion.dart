import 'package:flutter/animation.dart';

/// Duration tokens for animations
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration drawer = Duration(milliseconds: 400);

  // Aliases for compatibility
  static const Duration short = fast;
  static const Duration medium = normal;
  static const Duration standard = normal;
}

/// Curve tokens for animations
class AppCurves {
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve bounce = Curves.elasticOut;
  static const Curve drawer = Cubic(0.33, 1, 0.68, 1);

  // Additional curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
}

