import 'package:flutter/material.dart';
import 'package:sa2e7/pages/homepage.dart';
import 'package:sa2e7/welcome/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase/firbase_init.dart';
import 'firebase/fcm_notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
    // Initialize FCM after Firebase is ready
    await FCMNotificationHandler().initializeFCM();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Check if it's the first time the user opens the app
  Future<bool> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getBool('isFirstTime') ?? true;

    if (firstTime) {
      await prefs.setBool('isFirstTime', false);
    }

    return firstTime;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFirstTime(),
      builder: (context, snapshot) {
        // Show loading spinner while checking SharedPreferences
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // Handle error in SharedPreferences
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }

        // Decide which page to show
        final isFirstTime = snapshot.data ?? true;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Sa2e7",
          theme: ThemeData(primarySwatch: Colors.purple),
          home: isFirstTime ? const OnboardingScreen() : const HomePage(),
        );
      },
    );
  }
}
