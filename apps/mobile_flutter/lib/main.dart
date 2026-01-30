import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/app.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mobile_flutter/core/audio/audio_handler.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:mobile_flutter/core/config/app_config.dart';

import 'package:mobile_flutter/data/services/deep_link_service.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';
import 'package:mobile_flutter/data/services/security_service.dart';
import 'package:mobile_flutter/core/services/api_health_service.dart';

// Firebase imports removed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    MemoryAllocations.instance.addListener((event) {
      debugPrint('Memory: ${event.toString()}');
    });
  }
  await FlutterDownloader.initialize(debug: true);
  
  // Firebase initialization removed
  
  final audioHandler = await AudioService.init(
    builder: () => AudiogidAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.audioservice.channel.audio',
      androidNotificationChannelName: 'Audiogid Playback',
      androidNotificationOngoing: true,
    ),
  );

  final container = ProviderContainer(
    overrides: [
      audioHandlerProvider.overrideWithValue(audioHandler),
    ],
  );

  // Initialize global services
  container.read(deepLinkServiceProvider).init();
  container.read(notificationServiceProvider).init();
  container.read(analyticsServiceProvider).logEvent('app_open');
  // Check for root/jailbreak
  container.read(securityServiceProvider).checkDeviceSecurity();

  // API Connectivity Check
  try {
    final isHealthy = await container.read(apiHealthServiceProvider).checkHealth();
    if (!isHealthy) {
      debugPrint('API health check failed');
      // Potential UI feedback could go here
    }
  } catch (e) {
    debugPrint('API unreachable: $e');
  }

  // Check for pending deep link from terminated state
  try {
    final prefs = await SharedPreferences.getInstance();
    final pendingLink = prefs.getString('pending_deep_link');
    if (pendingLink != null) {
      final data = jsonDecode(pendingLink);
      container.read(deepLinkServiceProvider).handleDeepLink(data);
      await prefs.remove('pending_deep_link');
    }
  } catch (e) {
    debugPrint("Failed to handle pending deep link: $e");
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AudiogidApp(),
    ),
  );
}
