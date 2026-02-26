import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sa2e7/main.dart';
import 'package:sa2e7/pages/notifications_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Color definitions
  final Color primaryRed = const Color(0xFFD7141A);
  final Color primaryGreen = const Color(0xFF006B3C);

  // State variables for settings
  // (Other settings are managed in NotificationsPage)

  // ...existing code...

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Settings are managed in NotificationsPage
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryRed,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.brightness_6, color: primaryRed),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) async {
                  // Update the theme
                  themeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;

                  // Save preference
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isDarkMode', value);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications, color: primaryRed),
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
