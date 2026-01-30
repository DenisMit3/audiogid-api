import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notification channel IDs
class NotificationChannels {
  static const tourReminders = 'tour_reminders';
  static const pushMessages = 'push_messages';
  static const downloads = 'downloads';
}

/// Notification IDs for scheduled tour reminders
class NotificationIds {
  static const dailyReminder = 1000;
  static const tourReminderBase = 2000; // Tour-specific reminders start from here
}

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Initialize timezone for scheduled notifications
    tz.initializeTimeZones();
    
    // 1. Request Permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    debugPrint('Notification permission: ${settings.authorizationStatus}');
    
    // 2. Local Notifications Init with notification channels
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channels
    await _createNotificationChannels();

    // 3. Get Token
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token'); 
      // TODO: Send to backend
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // 4. Foreground Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
       _showLocalNotification(message);
    });
    
    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
        
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationChannels.tourReminders,
          'Напоминания о турах',
          description: 'Напоминания о запланированных турах',
          importance: Importance.high,
        ),
      );
      
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationChannels.pushMessages,
          'Push-уведомления',
          description: 'Уведомления от сервера',
          importance: Importance.max,
        ),
      );
      
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationChannels.downloads,
          'Загрузки',
          description: 'Уведомления о загрузках',
          importance: Importance.low,
        ),
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification clicked: ${response.payload}');
    
    // Parse payload and navigate
    final payload = response.payload;
    if (payload != null) {
      // Payload format: "type:id" e.g., "tour:123" or "poi:456"
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final type = parts[0];
        final id = parts[1];
        debugPrint('Navigate to $type with id $id');
        // Navigation will be handled by the app's navigation system
        // Store in preferences for the app to read on resume
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('pending_notification_navigation', payload);
        });
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await showNotification(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        channelId: NotificationChannels.pushMessages,
      );
    }
  }
  
  /// Show an immediate notification
  Future<void> showNotification({
    required int id, 
    String? title, 
    String? body, 
    String? payload,
    String channelId = NotificationChannels.tourReminders,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == NotificationChannels.tourReminders 
            ? 'Напоминания о турах' 
            : 'Push-уведомления',
          channelDescription: 'Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // ============== TOUR REMINDER SCHEDULING API ==============

  /// Schedule a daily reminder for tours at a specific time
  /// 
  /// [hour] and [minute] define the daily reminder time
  /// [title] and [body] are the notification content
  Future<void> scheduleDailyTourReminder({
    required int hour,
    required int minute,
    String title = 'Время для прогулки!',
    String body = 'Откройте Audiogid и начните путешествие',
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    // If the scheduled time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      NotificationIds.dailyReminder,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.tourReminders,
          'Напоминания о турах',
          channelDescription: 'Daily tour reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    
    debugPrint('Daily reminder scheduled for $hour:$minute');
  }

  /// Schedule a reminder for a specific tour at a specific time
  /// 
  /// [tourId] is used to generate a unique notification ID
  /// [scheduledDateTime] is when the reminder should fire
  Future<void> scheduleTourReminder({
    required String tourId,
    required String tourTitle,
    required DateTime scheduledDateTime,
    String? message,
  }) async {
    final notificationId = NotificationIds.tourReminderBase + tourId.hashCode.abs() % 1000;
    
    final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    
    await _localNotifications.zonedSchedule(
      notificationId,
      'Напоминание: $tourTitle',
      message ?? 'Пора начать тур!',
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.tourReminders,
          'Напоминания о турах',
          channelDescription: 'Tour-specific reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'tour:$tourId',
    );
    
    debugPrint('Tour reminder scheduled for $tourTitle at $scheduledDateTime');
    
    // Save reminder info to preferences for tracking
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('scheduled_tour_reminders') ?? [];
    reminders.add('$tourId|$notificationId|${scheduledDateTime.toIso8601String()}');
    await prefs.setStringList('scheduled_tour_reminders', reminders);
  }

  /// Schedule a reminder relative to now (e.g., "remind me in 2 hours")
  Future<void> scheduleRelativeTourReminder({
    required String tourId,
    required String tourTitle,
    required Duration delay,
    String? message,
  }) async {
    final scheduledTime = DateTime.now().add(delay);
    await scheduleTourReminder(
      tourId: tourId,
      tourTitle: tourTitle,
      scheduledDateTime: scheduledTime,
      message: message,
    );
  }

  /// Cancel a specific tour reminder
  Future<void> cancelTourReminder(String tourId) async {
    final notificationId = NotificationIds.tourReminderBase + tourId.hashCode.abs() % 1000;
    await _localNotifications.cancel(notificationId);
    
    // Remove from saved reminders
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('scheduled_tour_reminders') ?? [];
    reminders.removeWhere((r) => r.startsWith('$tourId|'));
    await prefs.setStringList('scheduled_tour_reminders', reminders);
    
    debugPrint('Cancelled reminder for tour $tourId');
  }

  /// Cancel the daily reminder
  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(NotificationIds.dailyReminder);
    debugPrint('Daily reminder cancelled');
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    await _localNotifications.cancelAll();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_tour_reminders');
    
    debugPrint('All reminders cancelled');
  }

  /// Get list of scheduled tour reminders
  Future<List<ScheduledTourReminder>> getScheduledReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList('scheduled_tour_reminders') ?? [];
    
    return reminders.map((r) {
      final parts = r.split('|');
      return ScheduledTourReminder(
        tourId: parts[0],
        notificationId: int.parse(parts[1]),
        scheduledTime: DateTime.parse(parts[2]),
      );
    }).where((r) => r.scheduledTime.isAfter(DateTime.now())).toList();
  }

  /// Check if notification permissions are granted
  Future<bool> hasNotificationPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Request notification permissions with explanation UI
  /// Returns true if permission was granted
  Future<bool> requestPermissionWithExplanation() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}

/// Represents a scheduled tour reminder
class ScheduledTourReminder {
  final String tourId;
  final int notificationId;
  final DateTime scheduledTime;

  ScheduledTourReminder({
    required this.tourId,
    required this.notificationId,
    required this.scheduledTime,
  });
}
