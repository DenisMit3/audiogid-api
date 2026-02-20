import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/app.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mobile_flutter/core/audio/audio_handler.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:mobile_flutter/core/config/app_config.dart';

import 'package:mobile_flutter/data/services/deep_link_service.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';
import 'package:mobile_flutter/data/services/security_service.dart';
import 'package:mobile_flutter/core/services/api_health_service.dart';

// #region agent log
void _debugLog(String location, String message, Map<String, dynamic> data) {
  try {
    final logFile = File('/data/data/app.audiogid.mobile_flutter/files/debug.log');
    final entry = jsonEncode({
      'sessionId': '03cf79',
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    logFile.writeAsStringSync('$entry\n', mode: FileMode.append, flush: true);
  } catch (e) {
    debugPrint('DEBUG_LOG_ERROR: $e');
  }
}
// #endregion

// Firebase imports removed

void main() async {
  // #region agent log
  _debugLog('main.dart:main:start', 'H4,H5: main() started', {'hypotheses': 'H4,H5'});
  // #endregion
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // #region agent log
  _debugLog('main.dart:after_binding', 'H15: WidgetsFlutterBinding initialized', {});
  // #endregion
  
  // #region agent log
  _debugLog('main.dart:before_downloader', 'H4: Before FlutterDownloader.initialize', {});
  // #endregion
  
  try {
    await FlutterDownloader.initialize(debug: kDebugMode);
    // #region agent log
    _debugLog('main.dart:after_downloader', 'H4: After FlutterDownloader.initialize', {});
    // #endregion
  } catch (e) {
    // #region agent log
    _debugLog('main.dart:downloader_error', 'H15: FlutterDownloader error', {'error': e.toString()});
    // #endregion
  }
  
  // Firebase initialization removed
  
  // #region agent log
  _debugLog('main.dart:before_audio', 'H5: Before AudioService.init', {});
  // #endregion
  
  late final AudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => AudiogidAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.audioservice.channel.audio',
        androidNotificationChannelName: 'Audiogid Playback',
        androidNotificationOngoing: true,
      ),
    );
    // #region agent log
    _debugLog('main.dart:after_audio', 'H5: After AudioService.init', {'audioHandler': audioHandler != null});
    // #endregion
  } catch (e) {
    // #region agent log
    _debugLog('main.dart:audio_error', 'H15: AudioService error', {'error': e.toString()});
    // #endregion
    rethrow;
  }

  // #region agent log
  _debugLog('main.dart:before_container', 'H15: Before ProviderContainer', {});
  // #endregion

  final container = ProviderContainer(
    overrides: [
      audioHandlerProvider.overrideWithValue(audioHandler),
    ],
  );

  // #region agent log
  _debugLog('main.dart:after_container', 'H15: After ProviderContainer', {});
  // #endregion

  // Initialize global services - wrap in try/catch
  try {
    container.read(deepLinkServiceProvider).init();
    // #region agent log
    _debugLog('main.dart:after_deeplink', 'H15: DeepLink init done', {});
    // #endregion
  } catch (e) {
    // #region agent log
    _debugLog('main.dart:deeplink_error', 'H15: DeepLink error', {'error': e.toString()});
    // #endregion
  }

  try {
    container.read(notificationServiceProvider).init();
    // #region agent log
    _debugLog('main.dart:after_notification', 'H15: Notification init done', {});
    // #endregion
  } catch (e) {
    // #region agent log
    _debugLog('main.dart:notification_error', 'H15: Notification error', {'error': e.toString()});
    // #endregion
  }

  try {
    container.read(analyticsServiceProvider).logEvent('app_open');
    // #region agent log
    _debugLog('main.dart:after_analytics', 'H15: Analytics done', {});
    // #endregion
  } catch (e) {
    // #region agent log
    _debugLog('main.dart:analytics_error', 'H15: Analytics error', {'error': e.toString()});
    // #endregion
  }

  try {
    container.read(securityServiceProvider).checkDeviceSecurity();
    // #region agent log
    _debugLog('main.dart:after_security', 'H15: Security check done', {});
    // #endregion
  } catch (e) {
    // #region agent log
    _debugLog('main.dart:security_error', 'H15: Security error', {'error': e.toString()});
    // #endregion
  }

  // API Connectivity Check
  try {
    final isHealthy = await container.read(apiHealthServiceProvider).checkHealth();
    // #region agent log
    _debugLog('main.dart:after_health', 'H15: API health check done', {'isHealthy': isHealthy});
    // #endregion
  } catch (e) {
    // #region agent log
    _debugLog('main.dart:health_error', 'H15: API health error', {'error': e.toString()});
    // #endregion
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
    // #region agent log
    _debugLog('main.dart:after_pending_link', 'H15: Pending link check done', {'hadLink': pendingLink != null});
    // #endregion
  } catch (e) {
    // #region agent log
    _debugLog('main.dart:pending_link_error', 'H15: Pending link error', {'error': e.toString()});
    // #endregion
  }

  // #region agent log
  _debugLog('main.dart:before_runApp', 'H15: Before runApp - FINAL', {});
  // #endregion

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AudiogidApp(),
    ),
  );
  
  // #region agent log
  _debugLog('main.dart:after_runApp', 'H15: After runApp called', {});
  // #endregion
}
