import 'package:flutter/material.dart';

import 'package:sa2e7/pages/notifications_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Color definitions
  final Color primaryBlue = const Color(0xFF3C82F6);
  final Color mintGreen = const Color(0xFF67D8C4);
  final Color darkBg = const Color(0xFF1A1A2E);

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
                  // Example: MyThemeProvider.of(context).setBrightness(value ? Brightness.dark : Brightness.light);
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
