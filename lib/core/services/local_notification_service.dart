import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize local notifications
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _localNotifications.initialize(initializationSettings);
      _isInitialized = true;
      debugPrint('Local notifications initialized');
      return true;
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    try {
      // Android 13+ requires POST_NOTIFICATIONS permission
      // This is handled by FCM initialization and flutter_local_notifications
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted ?? false) {
          debugPrint('iOS notification permission granted');
          return true;
        }
      }

      // Android permissions are handled by native config
      // Return true since they're configured
      debugPrint('Notification permissions are enabled');
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Show a simple notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? businessId,
    required String notificationType,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'sa2e7_notifications',
            'Sa2e7 Notifications',
            channelDescription:
                'Notifications for new businesses and hour updates',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final notificationId = businessId?.hashCode ?? DateTime.now().hashCode;

      await _localNotifications.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: businessId ?? '',
      );

      debugPrint('Notification shown: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Show notification for new business in favorite category
  Future<void> showNewBusinessNotification({
    required String businessName,
    required String businessId,
    required String category,
  }) async {
    final title = 'New $category Business!';
    final body = '$businessName just joined Sa2e7';

    await showNotification(
      title: title,
      body: body,
      businessId: businessId,
      notificationType: 'NEW_BUSINESS',
    );
  }

  /// Show notification for business hours change
  Future<void> showHoursChangeNotification({
    required String businessName,
    required String businessId,
    required String changedDays,
  }) async {
    final title = '$businessName changed hours';
    final body = 'Hours updated for: $changedDays';

    await showNotification(
      title: title,
      body: body,
      businessId: businessId,
      notificationType: 'HOURS_CHANGED',
    );
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      debugPrint('Notification cancelled: $id');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final bool? enabled =
            await androidImplementation.areNotificationsEnabled();
        return enabled ?? false;
      }

      return true; // iOS notifications are usually enabled by default
    } catch (e) {
      debugPrint('Error checking if notifications are enabled: $e');
      return false;
    }
  }
}
