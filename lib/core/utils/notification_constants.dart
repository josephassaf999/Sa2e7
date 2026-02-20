class NotificationConstants {
  // Notification types
  static const String newBusinessNotification = 'NEW_BUSINESS';
  static const String hoursChangedNotification = 'HOURS_CHANGED';

  // Categories
  static const List<String> categories = [
    'All',
    'Night Life',
    'Historical',
    'Beach',
    'Food',
    'Cave',
  ];

  // Notification titles and messages
  static String newBusinessTitle(String category) => 'New $category Business!';
  static String newBusinessBody(String businessName) =>
      '$businessName just joined Sa2e7';

  static String hoursChangedTitle(String businessName) =>
      '$businessName changed hours';
  static String hoursChangedBody(String changedDays) =>
      'Hours updated for: $changedDays';

  // FCM channel information
  static const String fcmChannelId = 'sa2e7_notifications';
  static const String fcmChannelName = 'Sa2e7 Notifications';
  static const String fcmChannelDescription =
      'Notifications for new businesses and hour updates';
}
