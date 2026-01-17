import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final Color primaryBlue = const Color(0xFF3C82F6);
  final Color mintGreen = const Color(0xFF67D8C4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Settings',style: TextStyle(color: Colors.white),),
        backgroundColor: primaryBlue,
      ),
      body: const Center(child: Text('Settings Page')),
    );
  }
}