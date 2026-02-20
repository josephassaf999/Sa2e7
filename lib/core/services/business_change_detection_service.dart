import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import '../utils/notification_constants.dart';

class BusinessChangeDetectionService {
  static final BusinessChangeDetectionService _instance =
      BusinessChangeDetectionService._internal();

  factory BusinessChangeDetectionService() {
    return _instance;
  }

  BusinessChangeDetectionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  /// Start monitoring for new businesses in user's preferred categories
  void startMonitoringNewBusinesses() {
    try {
      final currentUserId = _firebaseAuth.currentUser?.uid;
      if (currentUserId == null) return;

      _firestore.collection('Users').doc(currentUserId).snapshots().listen((
        userSnapshot,
      ) async {
        if (!userSnapshot.exists) return;

        final preferredCategories = List<String>.from(
          userSnapshot.data()?['preferredCategories'] ?? [],
        );

        if (preferredCategories.isEmpty) return;

        // Get notification settings to check if enabled
        final settings = userSnapshot.data()?['notificationSettings'] ?? {};
        final newBusinessEnabled = settings['newBusinessNotifications'] ?? true;

        if (!newBusinessEnabled) return;

        // Get current timestamp to avoid notifying about old businesses
        final lastCheckTime = DateTime.now().subtract(
          const Duration(minutes: 1),
        );

        // Listen to newly created businesses in preferred categories
        _firestore
            .collection('businesses')
            .where('category', whereIn: preferredCategories)
            .where(
              'createdAt',
              isGreaterThan: Timestamp.fromDate(lastCheckTime),
            )
            .snapshots()
            .listen((snapshot) async {
              for (var change in snapshot.docChanges) {
                if (change.type == DocumentChangeType.added) {
                  await _handleNewBusiness(currentUserId, change.doc);
                }
              }
            });
      });

      debugPrint('Started monitoring new businesses');
    } catch (e) {
      debugPrint('Error starting new business monitoring: $e');
    }
  }

  /// Handle a newly detected business
  Future<void> _handleNewBusiness(
    String userId,
    DocumentSnapshot businessDoc,
  ) async {
    try {
      final businessId = businessDoc.id;
      final businessName =
          businessDoc.data() is Map
              ? (businessDoc.data() as Map)['name'] ?? 'Unknown Business'
              : 'Unknown Business';
      final category =
          businessDoc.data() is Map
              ? (businessDoc.data() as Map)['category'] ?? 'All'
              : 'All';

      // Check if we already notified this user about this business
      final alreadyNotified = await _notificationService.hasAlreadyNotified(
        userId,
        businessId,
        NotificationConstants.newBusinessNotification,
      );

      if (alreadyNotified) return;

      // Log the notification
      await _notificationService.logNotification(
        userId: userId,
        notificationType: NotificationConstants.newBusinessNotification,
        businessId: businessId,
        businessName: businessName,
        additionalData: {'category': category},
      );

      debugPrint(
        'New business detected: $businessName ($businessId) in category $category',
      );
    } catch (e) {
      debugPrint('Error handling new business: $e');
    }
  }

  /// Start monitoring specific business for hour changes
  void startMonitoringBusinessHours(String businessId) {
    try {
      _firestore.collection('businesses').doc(businessId).snapshots().listen((
        businessSnapshot,
      ) async {
        if (!businessSnapshot.exists) return;

        final currentOpeningHours =
            businessSnapshot.data() is Map
                ? (businessSnapshot.data() as Map)['openingHours'] ?? {}
                : {};

        await _checkHourChanges(businessId, currentOpeningHours);
      });
    } catch (e) {
      debugPrint('Error monitoring business hours: $e');
    }
  }

  /// Check for hour changes and notify users who favorited this business
  Future<void> _checkHourChanges(
    String businessId,
    Map<String, dynamic> currentOpeningHours,
  ) async {
    try {
      // Get all users who favorited this business
      final usersQuery =
          await _firestore
              .collection('Users')
              .where('favorites', arrayContains: businessId)
              .get();

      // Get business name
      final businessDoc =
          await _firestore.collection('businesses').doc(businessId).get();
      final businessName =
          businessDoc.data() is Map
              ? (businessDoc.data() as Map)['name'] ?? 'Business'
              : 'Business';

      for (var userDoc in usersQuery.docs) {
        final userId = userDoc.id;

        // Check notification settings
        final settings = userDoc.data()['notificationSettings'] ?? {};
        final hoursChangeEnabled = settings['hoursChangeNotifications'] ?? true;

        if (!hoursChangeEnabled) continue;

        // Check if already notified
        final alreadyNotified = await _notificationService.hasAlreadyNotified(
          userId,
          businessId,
          NotificationConstants.hoursChangedNotification,
        );

        if (alreadyNotified) continue;

        // Detect which days changed
        final changedDays = _getChangedDays(currentOpeningHours);
        if (changedDays.isEmpty) continue;

        // Log the notification
        await _notificationService.logNotification(
          userId: userId,
          notificationType: NotificationConstants.hoursChangedNotification,
          businessId: businessId,
          businessName: businessName,
          additionalData: {'changedDays': changedDays},
        );

        debugPrint(
          'Hours changed for $businessName: $changedDays, notified user $userId',
        );
      }
    } catch (e) {
      debugPrint('Error checking hour changes: $e');
    }
  }

  /// Get which days had their hours changed
  List<String> _getChangedDays(Map<String, dynamic> openingHours) {
    try {
      // This is a simplified implementation
      // In production, you'd compare with previous hoursHistory
      List<String> days = [];

      final possibleDays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      for (var day in possibleDays) {
        if (openingHours.containsKey(day)) {
          final dayHours = openingHours[day] as Map?;
          if (dayHours != null && dayHours.isNotEmpty) {
            days.add(day);
          }
        }
      }

      // Return list of changed days
      return days.isNotEmpty ? days : [''];
    } catch (e) {
      debugPrint('Error getting changed days: $e');
      return [];
    }
  }

  /// Notify all users with a specific preferred category about a new business
  Future<void> notifyUsersAboutNewBusiness(DocumentSnapshot businessDoc) async {
    try {
      final businessId = businessDoc.id;
      final businessName =
          businessDoc.data() is Map
              ? (businessDoc.data() as Map)['name'] ?? 'Unknown Business'
              : 'Unknown Business';
      final category =
          businessDoc.data() is Map
              ? (businessDoc.data() as Map)['category'] ?? 'All'
              : 'All';

      // Get all users who want notifications for this category
      final usersQuery =
          await _firestore
              .collection('Users')
              .where('preferredCategories', arrayContains: category)
              .get();

      int notificationsSent = 0;

      for (var userDoc in usersQuery.docs) {
        final userId = userDoc.id;

        // Check notification settings
        final settings = userDoc.data()['notificationSettings'] ?? {};
        final newBusinessEnabled = settings['newBusinessNotifications'] ?? true;

        if (!newBusinessEnabled) continue;

        // Check if already notified
        final alreadyNotified = await _notificationService.hasAlreadyNotified(
          userId,
          businessId,
          NotificationConstants.newBusinessNotification,
        );

        if (alreadyNotified) continue;

        // Log notification
        await _notificationService.logNotification(
          userId: userId,
          notificationType: NotificationConstants.newBusinessNotification,
          businessId: businessId,
          businessName: businessName,
          additionalData: {'category': category},
        );

        notificationsSent++;
      }

      debugPrint(
        'Notified $notificationsSent users about new business: $businessName',
      );
    } catch (e) {
      debugPrint('Error notifying users about new business: $e');
    }
  }

  /// Notify users about hours change for a business
  Future<void> notifyUsersAboutHourChange(
    String businessId,
    List<String> changedDays,
  ) async {
    try {
      // Get business details
      final businessDoc =
          await _firestore.collection('businesses').doc(businessId).get();
      if (!businessDoc.exists) return;

      final businessName =
          businessDoc.data() is Map
              ? (businessDoc.data() as Map)['name'] ?? 'Business'
              : 'Business';

      // Get all users who favorited this business
      final usersQuery =
          await _firestore
              .collection('Users')
              .where('favorites', arrayContains: businessId)
              .get();

      int notificationsSent = 0;

      for (var userDoc in usersQuery.docs) {
        final userId = userDoc.id;

        // Check notification settings
        final settings = userDoc.data()['notificationSettings'] ?? {};
        final hoursChangeEnabled = settings['hoursChangeNotifications'] ?? true;

        if (!hoursChangeEnabled) continue;

        // Check if already notified
        final alreadyNotified = await _notificationService.hasAlreadyNotified(
          userId,
          businessId,
          NotificationConstants.hoursChangedNotification,
        );

        if (alreadyNotified) continue;

        // Log notification
        await _notificationService.logNotification(
          userId: userId,
          notificationType: NotificationConstants.hoursChangedNotification,
          businessId: businessId,
          businessName: businessName,
          additionalData: {'changedDays': changedDays.join(', ')},
        );

        notificationsSent++;
      }

      debugPrint(
        'Notified $notificationsSent users about hours change for $businessName',
      );
    } catch (e) {
      debugPrint('Error notifying users about hours change: $e');
    }
  }
}
