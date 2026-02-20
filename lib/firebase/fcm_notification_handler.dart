import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMNotificationHandler {
  static final FCMNotificationHandler _instance =
      FCMNotificationHandler._internal();

  factory FCMNotificationHandler() {
    return _instance;
  }

  FCMNotificationHandler._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback for handling notification taps
  Function(String? businessId)? onNotificationTap;

  /// Initialize FCM, local notifications, and handlers
  Future<void> initializeFCM() async {
    try {
      // Request notification permissions (iOS)
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get initial FCM token and store it
      final token = await getFCMToken();
      if (token.isNotEmpty) {
        await updateFCMTokenInFirestore(token);
      }

      // Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        updateFCMTokenInFirestore(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message (when app is terminated)
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle notification tap when app is in background/terminated
      FirebaseMessaging.instance.getInitialMessage().then(
        _handleNotificationTap,
      );

      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      debugPrint('FCM initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
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

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final businessId = response.payload;
        if (businessId != null && businessId.isNotEmpty) {
          onNotificationTap?.call(businessId);
        }
      },
    );
  }

  /// Get current FCM token
  Future<String> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token ?? '';
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return '';
    }
  }

  /// Update FCM token in Firestore
  Future<void> updateFCMTokenInFirestore(String token) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || token.isEmpty) return;

      final userRef = _firestore.collection('Users').doc(userId);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        // Get existing tokens or create empty list
        final existingTokens = List<String>.from(
          userDoc.data()?['fcmTokens'] ?? [],
        );

        // Remove token if it already exists (to avoid duplicates)
        existingTokens.removeWhere((t) => t == token);

        // Add new token at the beginning
        existingTokens.insert(0, token);

        // Keep only last 5 tokens
        if (existingTokens.length > 5) {
          existingTokens.removeRange(5, existingTokens.length);
        }

        // Update user document
        await userRef.update({'fcmToken': token, 'fcmTokens': existingTokens});

        debugPrint('FCM token updated in Firestore');
      }
    } catch (e) {
      debugPrint('Error updating FCM token in Firestore: $e');
    }
  }

  /// Handle foreground messages (app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Handling foreground message: ${message.messageId}');

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show local notification
      await _showLocalNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        businessId: data['businessId'],
        notificationType: data['type'],
      );
    }
  }

  /// Handle background message (app is terminated)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Handling background message: ${message.messageId}');
    // This runs in an isolate and cannot update UI directly
    // Just log or process as needed
  }

  /// Handle notification tap
  Future<void> _handleNotificationTap(RemoteMessage? message) async {
    if (message != null) {
      final businessId = message.data['businessId'];
      debugPrint('Notification tapped, businessId: $businessId');
      if (businessId != null && businessId.isNotEmpty) {
        onNotificationTap?.call(businessId);
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? businessId,
    String? notificationType,
  }) async {
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

      await _localNotifications.show(
        businessId?.hashCode ?? 0,
        title,
        body,
        platformChannelSpecifics,
        payload: businessId ?? '',
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Send notification for new business
  Future<void> sendNewBusinessNotification({
    required String userId,
    required String businessName,
    required String businessId,
    required String category,
  }) async {
    try {
      final userRef = _firestore.collection('Users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) return;

      final fcmTokens = List<String>.from(userDoc.data()?['fcmTokens'] ?? []);

      if (fcmTokens.isEmpty) return;

      // Note: In production, you'd send this via Cloud Functions
      // For now, this is a placeholder for the notification sending logic
      debugPrint(
        'Would send new business notification to $userId for $businessName',
      );
    } catch (e) {
      debugPrint('Error sending new business notification: $e');
    }
  }

  /// Send notification for hours change
  Future<void> sendHoursChangeNotification({
    required String userId,
    required String businessName,
    required String businessId,
    required String changedDays,
  }) async {
    try {
      final userRef = _firestore.collection('Users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) return;

      final fcmTokens = List<String>.from(userDoc.data()?['fcmTokens'] ?? []);

      if (fcmTokens.isEmpty) return;

      // Note: In production, you'd send this via Cloud Functions
      debugPrint(
        'Would send hours change notification to $userId for $businessName: $changedDays',
      );
    } catch (e) {
      debugPrint('Error sending hours change notification: $e');
    }
  }
}
