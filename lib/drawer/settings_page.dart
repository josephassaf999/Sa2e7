import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa2e7/core/services/notification_service.dart';
import 'package:sa2e7/core/utils/notification_constants.dart';
import 'package:sa2e7/firebase/fcm_notification_handler.dart';

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

  bool _enableAllNotifications = true;
  bool _enableNewBusinessNotifications = true;
  bool _enableHoursChangeNotifications = true;
  List<String> _selectedCategories = [];
  String _fcmToken = 'Loading...';
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() => _isLoading = false);
    }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully'),
            backgroundColor: primaryBlue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error saving settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleMasterSwitch(bool value) {
    setState(() {
      _enableAllNotifications = value;
      _enableNewBusinessNotifications = value;
      _enableHoursChangeNotifications = value;
    });
  }

  void _toggleNewBusinessNotifications(bool value) {
    setState(() {
      _enableNewBusinessNotifications = value;
      _enableAllNotifications =
          _enableNewBusinessNotifications && _enableHoursChangeNotifications;
    });
  }

  void _toggleHoursChangeNotifications(bool value) {
    setState(() {
      _enableHoursChangeNotifications = value;
      _enableAllNotifications =
          _enableNewBusinessNotifications && _enableHoursChangeNotifications;
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
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
        backgroundColor: primaryBlue,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryBlue))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Master notification toggle
                      _buildSectionHeader('Enable Notifications'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'All Notifications',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Manage all notification types',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _enableAllNotifications,
                                onChanged: _toggleMasterSwitch,
                                activeColor: mintGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Notification types
                      _buildSectionHeader('Notification Types'),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text(
                                'New Businesses in My Categories',
                              ),
                              subtitle: const Text(
                                'Get notified when a new business opens in your favorite categories',
                              ),
                              trailing: Switch(
                                value: _enableNewBusinessNotifications,
                                onChanged:
                                    _enableAllNotifications
                                        ? _toggleNewBusinessNotifications
                                        : null,
                                activeColor: mintGreen,
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
                                onChanged:
                                    _enableAllNotifications
                                        ? _toggleHoursChangeNotifications
                                        : null,
                                activeColor: mintGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category selection
                      _buildSectionHeader('My Interests'),
                      Text(
                        'Select categories you\'re interested in to receive notifications about new businesses',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            NotificationConstants.categories
                                .where((cat) => cat != 'All')
                                .map((category) {
                                  final isSelected = _selectedCategories
                                      .contains(category);
                                  return FilterChip(
                                    label: Text(category),
                                    selected: isSelected,
                                    onSelected:
                                        _enableAllNotifications
                                            ? (_) => _toggleCategory(category)
                                            : null,
                                    selectedColor: mintGreen.withOpacity(0.7),
                                    backgroundColor: Colors.grey[300],
                                    labelStyle: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                      if (_selectedCategories.isEmpty &&
                          _enableAllNotifications)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              border: Border.all(color: Colors.amber, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.amber[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Select at least one category to receive notifications',
                                    style: TextStyle(
                                      color: Colors.amber[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Debug section
                      _buildSectionHeader('Debug Information'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FCM Token:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: SelectableText(
                                  _fcmToken,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final token = await _fcmHandler.getFCMToken();
                                  if (mounted) {
                                    setState(() {
                                      _fcmToken =
                                          token.isNotEmpty
                                              ? '${token.substring(0, 20)}...'
                                              : 'No token available';
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'FCM token refreshed',
                                        ),
                                        backgroundColor: primaryBlue,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh Token'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Save Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: primaryBlue,
        ),
      ),
    );
  }
}
