import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/app.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mobile_flutter/core/audio/audio_handler.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile_flutter/data/services/deep_link_service.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';

/// Background message handler for FCM
/// Must be a top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');
  
  // Handle background message data
  // For deep links from push: data might contain 'type' and 'target_id'
  final data = message.data;
  if (data['type'] == 'poi' || data['type'] == 'tour') {
    // Store in local storage for handling when app opens
    // The deep link service will pick this up on app resume
    debugPrint('Background push for ${data['type']}: ${data['target_id']}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);

  try {
    await Firebase.initializeApp();
    
    // Register background message handler for FCM
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle notification taps when app was terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification: ${initialMessage.data}');
      // The deep link service will handle this
    }
    
    // Handle notification taps when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app from background: ${message.data}');
      // Navigate based on message data
      final data = message.data;
      if (data['type'] == 'poi') {
        // Navigate to POI - will be handled by deep link service
      } else if (data['type'] == 'tour') {
        // Navigate to Tour
      }
    });
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  
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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AudiogidApp(),
    ),
  );
}
