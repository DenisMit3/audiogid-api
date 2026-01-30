import 'dart:async';
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
        _trackAttribution(initialUri);
      }
    } catch (e) {
      debugPrint('DeepLink Error: $e');
    }

    // Listen to changes
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _trackAttribution(uri);
      // If we needed to manually navigate (e.g. for QR codes scanned IN app), we would do it here or via a dedicated method.
    }, onError: (err) {
      debugPrint('DeepLink Stream Error: $err');
    });
  }



  Future<void> _trackAttribution(Uri uri) async {
    if (uri.queryParameters.containsKey('utm_source')) {
      debugPrint('Attribution Tracked: ${uri.queryParameters}');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('attribution_source', uri.queryParameters['utm_source']!);
        if (uri.queryParameters.containsKey('utm_campaign')) {
           await prefs.setString('attribution_campaign', uri.queryParameters['utm_campaign']!);
        }
      } catch (e) {
        debugPrint('Error saving attribution: $e');
      }
    }
  }
  
  void dispose() {
    _sub?.cancel();
  }
}
