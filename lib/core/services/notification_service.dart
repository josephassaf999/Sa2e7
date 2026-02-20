import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Get user's preferred categories
  Future<List<String>> getPreferredCategories(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (!doc.exists) return [];
      return List<String>.from(doc.data()?['preferredCategories'] ?? []);
    } catch (e) {
      debugPrint('Error getting preferred categories: $e');
      return [];
    }
  }

  /// Set user's preferred categories
  Future<void> setPreferredCategories(
    String userId,
    List<String> categories,
  ) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'preferredCategories': categories,
      });
      debugPrint('Preferred categories updated: $categories');
    } catch (e) {
      debugPrint('Error setting preferred categories: $e');
    }
  }

  /// Get notification settings for a user
  Future<Map<String, dynamic>> getNotificationSettings(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (!doc.exists) {
        return {
          'newBusinessNotifications': true,
          'hoursChangeNotifications': true,
        };
      }
      return doc.data()?['notificationSettings'] ??
          {'newBusinessNotifications': true, 'hoursChangeNotifications': true};
    } catch (e) {
      debugPrint('Error getting notification settings: $e');
      return {
        'newBusinessNotifications': true,
        'hoursChangeNotifications': true,
      };
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'notificationSettings': {
          ...settings,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      });
      debugPrint('Notification settings updated');
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
    }
  }

  /// Get users with a specific category preference
  Future<List<String>> getUsersWithCategory(String category) async {
    try {
      final query =
          await _firestore
              .collection('Users')
              .where('preferredCategories', arrayContains: category)
              .get();

      return query.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error querying users with category: $e');
      return [];
    }
  }

  /// Check if we already notified a user about a business
  Future<bool> hasAlreadyNotified(
    String userId,
    String businessId,
    String notificationType,
  ) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (!doc.exists) return false;

      final history = List<Map<dynamic, dynamic>>.from(
        doc.data()?['notificationHistory'] ?? [],
      );

      // Check if already notified in the last 24 hours
      final now = DateTime.now();
      final oneDayAgo = now.subtract(const Duration(days: 1));

      for (var notification in history) {
        final timestamp = notification['timestamp'] as Timestamp?;
        final notifBusinessId = notification['businessId'] as String?;
        final type = notification['type'] as String?;

        if (notifBusinessId == businessId &&
            type == notificationType &&
            timestamp != null &&
            timestamp.toDate().isAfter(oneDayAgo)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking notification history: $e');
      return false;
    }
  }

  /// Log a notification to user's history
  Future<void> logNotification({
    required String userId,
    required String notificationType,
    required String businessId,
    required String businessName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userRef = _firestore.collection('Users').doc(userId);
      final notificationId =
          '${businessId}_${DateTime.now().millisecondsSinceEpoch}';

      final notificationData = {
        'notificationId': notificationId,
        'type': notificationType,
        'businessId': businessId,
        'businessName': businessName,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        if (additionalData != null) ...additionalData,
      };

      // Add to notification history with array size limit
      await userRef.update({
        'notificationHistory': FieldValue.arrayUnion([notificationData]),
      });

      // Cleanup old notifications (keep only last 50)
      final userDoc = await userRef.get();
      final history = List<Map<dynamic, dynamic>>.from(
        userDoc.data()?['notificationHistory'] ?? [],
      );

      if (history.length > 50) {
        // Sort by timestamp and keep only latest 50
        history.sort((a, b) {
          final aTime =
              (a['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bTime =
              (b['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });

        final trimmedHistory = history.take(50).toList();
        await userRef.update({'notificationHistory': trimmedHistory});
      }

      debugPrint('Notification logged for user: $userId');
    } catch (e) {
      debugPrint('Error logging notification: $e');
    }
  }

  /// Get current user's preferred categories
  Future<List<String>> getCurrentUserPreferredCategories() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return [];
    return getPreferredCategories(userId);
  }

  /// Get current user's notification settings
  Future<Map<String, dynamic>> getCurrentUserNotificationSettings() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return {};
    return getNotificationSettings(userId);
  }

  /// Save user's notification preferences (settings + categories)
  Future<void> saveNotificationPreferences({
    required String userId,
    required List<String> preferredCategories,
    required bool enableNewBusinessNotifications,
    required bool enableHoursChangeNotifications,
  }) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'preferredCategories': preferredCategories,
        'notificationSettings': {
          'newBusinessNotifications': enableNewBusinessNotifications,
          'hoursChangeNotifications': enableHoursChangeNotifications,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      });
      debugPrint('Notification preferences saved');
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    try {
      final userRef = _firestore.collection('Users').doc(userId);
      final userDoc = await userRef.get();
      final history = List<Map<dynamic, dynamic>>.from(
        userDoc.data()?['notificationHistory'] ?? [],
      );

      for (int i = 0; i < history.length; i++) {
        if (history[i]['notificationId'] == notificationId) {
          history[i]['read'] = true;
          break;
        }
      }

      await userRef.update({'notificationHistory': history});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}
