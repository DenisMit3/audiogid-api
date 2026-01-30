import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
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
      bool jailbroken = await FlutterJailbreakDetection.jailbroken;
      bool developerMode = await FlutterJailbreakDetection.developerMode;

      // We might tolerate dev mode, but strictly flag jailbreak
      if (jailbroken) {
        _isDeviceCompromised = true;
        await _analytics.setUserProperty('is_rooted', 'true');
        await _analytics.logEvent('security_alert', {
          'type': 'root_detected',
          'developer_mode': developerMode,
        });
        debugPrint('SECURITY ALERT: Device is rooted/jailbroken.');
      } else {
        await _analytics.setUserProperty('is_rooted', 'false');
      }
    } catch (e) {
      debugPrint('Security Check Failed: $e');
    }
  }

  bool get isDeviceCompromised => _isDeviceCompromised;
}
