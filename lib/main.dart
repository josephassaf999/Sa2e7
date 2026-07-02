import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sa2e7/pages/homepage.dart';
import 'package:sa2e7/welcome/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sa2e7/core/themes/app_theme.dart';
import 'firebase/firbase_init.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Cache for app state to avoid duplicate SharedPreferences loads
late SharedPreferences _cachedPrefs;
bool? _cachedFirstTime;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load both Firebase and SharedPreferences in parallel (not FCM yet)
  try {
    await Future.wait([initializeFirebase(), _initializeAppState()]);
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const MyApp());
}

/// Initialize app state (theme + first time check) in parallel with Firebase
Future<void> _initializeAppState() async {
  _cachedPrefs = await SharedPreferences.getInstance();
  _cachedFirstTime = _cachedPrefs.getBool('isFirstTime') ?? true;

  final isDark = _cachedPrefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        // Mark first time as visited (non-blocking)
        if (_cachedFirstTime == true) {
          _cachedPrefs.setBool('isFirstTime', false);
        }

        return StreamProvider<User?>(
          create: (context) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Sa2e7",
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home:
                _cachedFirstTime ?? true
                    ? const OnboardingScreen()
                    : const HomePage(),
          ),
        );
      },
    );
  }
}
