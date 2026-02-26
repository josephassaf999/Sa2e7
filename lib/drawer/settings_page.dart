import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sa2e7/core/services/notification_service.dart';

import 'package:sa2e7/firebase/fcm_notification_handler.dart';
import 'package:sa2e7/pages/notifications_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color primaryBlue = const Color(0xFF3C82F6);
  final Color mintGreen = const Color(0xFF67D8C4);
  final Color darkBg = const Color(0xFF1A1A2E);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  final FCMNotificationHandler _fcmHandler = FCMNotificationHandler();

  // State variables for settings
  List<String> _selectedCategories = [];
  bool _enableNewBusinessNotifications = true;
  bool _enableHoursChangeNotifications = true;
  bool _enableAllNotifications = true;
  String _fcmToken = '';
  bool _isLoading = true;

  // ...existing code...

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      // Not logged in — stop spinner and show empty state
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final categories = await _notificationService.getPreferredCategories(
        userId,
      );
      final settings = await _notificationService.getNotificationSettings(
        userId,
      );
      final token = await _fcmHandler.getFCMToken();

      setState(() {
        _selectedCategories = categories;
        _enableNewBusinessNotifications =
            settings['newBusinessNotifications'] ?? true;
        _enableHoursChangeNotifications =
            settings['hoursChangeNotifications'] ?? true;
        _enableAllNotifications =
            _enableNewBusinessNotifications && _enableHoursChangeNotifications;
        _fcmToken =
            token.isNotEmpty
                ? '${token.substring(0, 20)}...'
                : 'No token available';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() => _isLoading = false);
    }
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.brightness_6, color: primaryBlue),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  // This assumes you have a theme provider or similar mechanism
                  // Replace this with your actual theme switching logic
                  final brightness = value ? Brightness.dark : Brightness.light;
                  // Example: MyThemeProvider.of(context).setBrightness(brightness);
                  // For demonstration, show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Theme switching not implemented. Implement your theme logic.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications, color: primaryBlue),
              title: const Text('Notification Settings'),
              subtitle: const Text('Manage notification preferences'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    // ...replaced by new ListView above...
  }

  // ...existing code...
}

class SettingsOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
