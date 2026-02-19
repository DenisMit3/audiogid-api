import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService(ref.read(analyticsServiceProvider));
});

class SecurityService {
  final AnalyticsService _analytics;
  bool _isDeviceCompromised = false;

  SecurityService(this._analytics);

  Future<void> checkDeviceSecurity() async {
    try {
      // Jailbreak detection disabled - flutter_jailbreak_detection removed
      // TODO: Add alternative security check if needed
      await _analytics.logEvent('security_check', {'is_rooted': 'unknown'});
      debugPrint('Security check: jailbreak detection disabled');
    } catch (e) {
      debugPrint('Security Check Failed: $e');
    }
  }

  bool get isDeviceCompromised => _isDeviceCompromised;
}
