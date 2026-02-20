import 'package:flutter/material.dart';

/// Onboarding UI Constants
class OnboardingUIConstants {
  static const Color primaryRed = Color(0xFFED1C24);

  // String constants
  static const String skipButton = 'Skip';
  static const String nextButton = 'Next';
  static const String getStartedButton = 'Get Started';

  static const String page1Title = 'Welcome to Sa2e7';
  static const String page1Subtitle =
      'Discover destinations, experiences, and hidden gems around you.';

  static const String page2Title = 'Plan Your Journey';
  static const String page2Subtitle =
      'Find places, activities, and trips that match your vibe.';

  static const String page3Title = 'Explore With Confidence';
  static const String page3Subtitle =
      'Navigate easily and make every adventure unforgettable.';

  // Assets
  static const String heroImage = 'assets/image/lebhero.png';
  static const String mapAnimation = 'assets/lottie/Map.json';
  static const String compassAnimation = 'assets/lottie/Compass.json';
}

/// Onboarding UI Utilities
class OnboardingUIUtils {
  // ─── PAGE INDICATOR EFFECT ─────────────────────────────────────────────────
  static const dotHeight = 10.0;
  static const dotWidth = 10.0;
  static const expansionFactor = 3.0;

  // ─── ANIMATIONS ────────────────────────────────────────────────────────────
  static const animationDuration = Duration(milliseconds: 400);
  static const switchDuration = Duration(milliseconds: 700);

  // ─── BUTTON STYLE ──────────────────────────────────────────────────────────
  static ButtonStyle nextButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
    );
  }
}
