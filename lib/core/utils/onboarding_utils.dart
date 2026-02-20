import 'package:flutter/material.dart';

/// Onboarding UI Constants
class OnboardingUIConstants {
  static const Color primaryRed = Color(0xFFED1C24);
  static const Color primaryRedDark = Color(0xFFD41820);
  static const Color accentRed = Color(0xFFC9140F);
  static const Color cardBg = Color(0xFFFAFAFA);
  static const Color shadowColor = Color(0x1A000000);

  // String constants
  static const String skipButton = 'Skip';
  static const String nextButton = 'Next';
  static const String getStartedButton = 'Get Started';
  static const String backButton = 'Back';

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
  static const dotHeight = 8.0;
  static const dotWidth = 8.0;
  static const expansionFactor = 2.5;

  // ─── ANIMATIONS ────────────────────────────────────────────────────────────
  static const animationDuration = Duration(milliseconds: 400);
  static const switchDuration = Duration(milliseconds: 600);
  static const textAnimationDuration = Duration(milliseconds: 800);

  // ─── BUTTON STYLE ──────────────────────────────────────────────────────────
  static ButtonStyle floatingNextButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      backgroundColor: OnboardingUIConstants.primaryRed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 8,
      shadowColor: OnboardingUIConstants.primaryRed.withOpacity(0.4),
    );
  }

  static ButtonStyle floatingBackButtonStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      side: const BorderSide(color: OnboardingUIConstants.primaryRed, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    );
  }

  // ─── BACKGROUND GRADIENT ──────────────────────────────────────────────────
  static LinearGradient backgroundGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        OnboardingUIConstants.primaryRed,
        OnboardingUIConstants.primaryRedDark,
      ],
    );
  }

  // ─── CARD SHADOW ───────────────────────────────────────────────────────────
  static BoxShadow cardShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    );
  }
}

