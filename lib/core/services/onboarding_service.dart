import 'package:shared_preferences/shared_preferences.dart';

/// Service for Onboarding logic
class OnboardingService {
  // ─── FINISH ONBOARDING ─────────────────────────────────────────────────────
  static Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  // ─── CHECK IF FIRST TIME ───────────────────────────────────────────────────
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }
}
