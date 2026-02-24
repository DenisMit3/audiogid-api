import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription? _sub;

  // Callback to be set by the UI/Router layer to handle navigation if needed,
  // or we can rely on GoRouter's declarative routing if the OS passes the intent.
  // But for Attribution, we need to inspect.

  Future<void> init() async {
    // Check initial link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        if (_verifySignature(initialUri)) {
          _trackAttribution(initialUri);
        } else {
          debugPrint('DeepLink Signature Verification Failed: $initialUri');
        }
      }
    } catch (e) {
      debugPrint('DeepLink Error: $e');
    }

    // Listen to changes
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (_verifySignature(uri)) {
        _trackAttribution(uri);
      } else {
        debugPrint('DeepLink Signature Verification Failed: $uri');
      }
      // If we needed to manually navigate (e.g. for QR codes scanned IN app), we would do it here or via a dedicated method.
    }, onError: (err) {
      debugPrint('DeepLink Stream Error: $err');
    });
  }

  bool _verifySignature(Uri uri) {
    final token = uri.queryParameters['token'];
    final timestamp = uri.queryParameters['timestamp'];
    final signature = uri.queryParameters['signature'];

    // If no signature is present, we assume it's a public link and allow it.
    // Adjust this logic if ALL links must be signed.
    if (token == null || signature == null) return true;

    const secretKey = String.fromEnvironment('DEEP_LINK_SECRET',
        defaultValue: 'CHANGE_ME_IN_PROD');

    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final digest = hmac.convert(utf8.encode('$token:$timestamp'));

    return digest.toString() == signature;
  }

  Future<void> _trackAttribution(Uri uri) async {
    final utmSource = uri.queryParameters['utm_source'];
    final utmCampaign = uri.queryParameters['utm_campaign'];

    // Whitelist validation
    const allowedSources = {
      'qr',
      'telegram',
      'partner_a',
      'website',
      'email_campaign'
    };
    final validPattern = RegExp(r'^[a-zA-Z0-9_]+$');

    if (utmSource != null &&
        (allowedSources.contains(utmSource) ||
            validPattern.hasMatch(utmSource))) {
      debugPrint('Attribution Tracked: $utmSource');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('attribution_source', utmSource);

        if (utmCampaign != null && validPattern.hasMatch(utmCampaign)) {
          await prefs.setString('attribution_campaign', utmCampaign);
        }
      } catch (e) {
        debugPrint('Error saving attribution: $e');
      }
    } else if (utmSource != null) {
      debugPrint('Attribution source rejected: $utmSource');
    }
  }

  void dispose() {
    _sub?.cancel();
  }

  /// Handle a deep link from external source (e.g., pending link from terminated state)
  void handleDeepLink(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    if (type != null && id != null) {
      debugPrint('Handling deep link: type=$type, id=$id');
      // Navigation will be handled by GoRouter based on the current route
      // For now, just track attribution if present
      final utmSource = data['utm_source'] as String?;
      if (utmSource != null) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('attribution_source', utmSource);
        });
      }
    }
  }
}
