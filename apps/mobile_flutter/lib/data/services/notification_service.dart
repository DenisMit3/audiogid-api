import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/router/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

part 'notification_service.g.dart';

/// Notification channel IDs
class NotificationChannels {
  static const tourReminders = 'tour_reminders';
  static const pushMessages = 'push_messages';
  static const downloads = 'downloads';
}

/// Notification IDs for scheduled tour reminders
class NotificationIds {
  static const dailyReminder = 1000;
  static const tourReminderBase = 2000;
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService(ref);
}

class NotificationService {
  final Ref _ref;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService(this._ref);

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Initialize timezone for scheduled notifications
    tz_data.initializeTimeZones();
    
    // Local Notifications Init
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channels
    await _createNotificationChannels();
    
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
    
    final payload = response.payload;
    if (payload != null) {
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final type = parts[0];
        final id = parts[1];
        debugPrint('Navigate to $type with id $id');
        
        try {
          final router = _ref.read(routerProvider);
          if (type == 'tour') {
            router.push('/tour/$id');
          } else if (type == 'poi') {
            router.push('/poi/$id');
          }
        } catch (e) {
          debugPrint("Navigation error: $e");
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('pending_notification_navigation', payload);
          });
        }
      }
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
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
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

  /// Show a local notification with custom data
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    final payloadStr = payload != null 
        ? '${payload['type']}:${payload['id']}' 
        : null;
    
    await showNotification(
      id: id,
      title: title,
      body: body,
      payload: payloadStr,
      channelId: NotificationChannels.pushMessages,
    );
  }

  /// Schedule a daily reminder for tours at a specific time
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
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      id: NotificationIds.dailyReminder,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    debugPrint('Daily reminder scheduled for $hour:$minute');
  }

  /// Schedule a reminder for a specific tour
  Future<void> scheduleTourReminder({
    required String tourId,
    required String tourTitle,
    required DateTime scheduledDateTime,
    String? message,
  }) async {
    final notificationId = NotificationIds.tourReminderBase + tourId.hashCode.abs() % 1000;
    
    final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    
    await _localNotifications.zonedSchedule(
      id: notificationId,
      title: 'Напоминание: $tourTitle',
      body: message ?? 'Пора начать тур!',
      scheduledDate: tzDateTime,
      notificationDetails: NotificationDetails(
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
      payload: 'tour:$tourId',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    
    debugPrint('Tour reminder scheduled for $tourTitle at $scheduledDateTime');
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    await _localNotifications.cancel(id: notificationId);
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(id: NotificationIds.dailyReminder);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      return await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }
    return true;
  }

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    return await areNotificationsEnabled();
  }

  /// Request permission with explanation dialog
  Future<bool> requestPermissionWithExplanation() async {
    return await requestPermissions();
  }

  /// Cancel a tour-specific reminder
  Future<void> cancelTourReminder(String tourId) async {
    final notificationId = NotificationIds.tourReminderBase + tourId.hashCode.abs() % 1000;
    await cancelNotification(notificationId);
  }

  /// Schedule a relative tour reminder (e.g., 1 hour from now)
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
}
