import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa2e7/core/services/notification_service.dart';
import 'package:sa2e7/firebase/fcm_notification_handler.dart';
import 'package:sa2e7/core/utils/notification_constants.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  List<String> get _allCategories =>
      NotificationConstants.categories.where((c) => c != 'All').toList();
  final Color primaryRed = const Color(0xFFE53935);
  final Color accentRed = const Color(0xFFFF8A65);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  final FCMNotificationHandler _fcmHandler = FCMNotificationHandler();

  bool _enableAllNotifications = true;
  bool _enableNewBusinessNotifications = true;
  bool _enableHoursChangeNotifications = true;
  List<String> _selectedCategories = [];
  String _fcmToken = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;
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
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  void _toggleMasterSwitch(bool value) {
    setState(() {
      _enableAllNotifications = value;
      _enableNewBusinessNotifications = value;
      _enableHoursChangeNotifications = value;
    });
    _saveSettings();
  }

  void _toggleNewBusinessNotifications(bool value) {
    setState(() {
      _enableNewBusinessNotifications = value;
      _enableAllNotifications = value && _enableHoursChangeNotifications;
    });
    _saveSettings();
  }

  void _toggleHoursChangeNotifications(bool value) {
    setState(() {
      _enableHoursChangeNotifications = value;
      _enableAllNotifications = _enableNewBusinessNotifications && value;
    });
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _notificationService.saveNotificationPreferences(
        userId: userId,
        preferredCategories: _selectedCategories,
        enableNewBusinessNotifications: _enableNewBusinessNotifications,
        enableHoursChangeNotifications: _enableHoursChangeNotifications,
      );
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryRed,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_active, color: primaryRed),
              title: const Text('Enable All Notifications'),
              trailing: Switch(
                value: _enableAllNotifications,
                activeColor: accentRed,
                onChanged: _toggleMasterSwitch,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('New Businesses in My Categories'),
                  subtitle: const Text(
                    'Get notified when a new business opens in your favorite categories',
                  ),
                  trailing: Switch(
                    value: _enableNewBusinessNotifications,
                    onChanged: _toggleNewBusinessNotifications,
                    activeColor: accentRed,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Hours Changes'),
                  subtitle: const Text(
                    'Get notified when business hours change for your saved businesses',
                  ),
                  trailing: Switch(
                    value: _enableHoursChangeNotifications,
                    onChanged: _toggleHoursChangeNotifications,
                    activeColor: accentRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Favorite Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _allCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                      _saveSettings();
                    },
                    selectedColor: accentRed.withOpacity(0.7),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
