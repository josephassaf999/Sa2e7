import 'package:flutter/material.dart';

/// Centralized design tokens for the Sa2e7 app
/// This file defines all color, typography, spacing, and layout constants
/// to ensure consistency across the entire application

class DesignTokens {
  // ─────────────────────────────────────────────────────────────────────
  // COLORS - PRIMARY PALETTE
  // ─────────────────────────────────────────────────────────────────────

  /// Primary brand color - Red used throughout the app
  static const Color primaryRed = Color(0xFFD7141A);
  static const Color primaryRedDark = Color(0xFFD41820);
  static const Color primaryRedLight = Color(0xFFED1C24);

  /// Secondary brand colors
  static const Color primaryGreen = Color(0xFF006B3C);
  static const Color primaryGreenLight = Color(0xFF00A352);

  // ─────────────────────────────────────────────────────────────────────
  // COLORS - SEMANTIC
  // ─────────────────────────────────────────────────────────────────────

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantLight = Color(0xFFFAFAFA);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);

  static const Color outlineLight = Color(0xFFE0E0E0);
  static const Color outlineDark = Color(0xFF444444);

  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color infoColor = Color(0xFF1976D2);

  // ─────────────────────────────────────────────────────────────────────
  // COLORS - TEXT
  // ─────────────────────────────────────────────────────────────────────

  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFFAFAFA);

  static const Color textSecondaryLight = Color(0xFF616161);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  static const Color textTertiaryLight = Color(0xFF9E9E9E);
  static const Color textTertiaryDark = Color(0xFF757575);

  static const Color textInvertedLight = Color(0xFFFFFFFF);
  static const Color textInvertedDark = Color(0xFF212121);

  // ─────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY - FONT FAMILY
  // ─────────────────────────────────────────────────────────────────────

  static const String fontFamily = 'Roboto';

  // ─────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY - FONT SIZES
  // ─────────────────────────────────────────────────────────────────────

  static const double fontSizeHeadline1 = 32.0;
  static const double fontSizeHeadline2 = 28.0;
  static const double fontSizeHeadline3 = 24.0;
  static const double fontSizeTitle1 = 20.0;
  static const double fontSizeTitle2 = 18.0;
  static const double fontSizeBody1 = 16.0;
  static const double fontSizeBody2 = 14.0;
  static const double fontSizeCaption = 12.0;
  static const double fontSizeOverline = 11.0;

  // ─────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY - FONT WEIGHTS
  // ─────────────────────────────────────────────────────────────────────

  static const FontWeight fontWeightThin = FontWeight.w100;
  static const FontWeight fontWeightExtraLight = FontWeight.w200;
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  // ─────────────────────────────────────────────────────────────────────
  // SPACING - 8DP GRID SYSTEM
  // ─────────────────────────────────────────────────────────────────────

  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing36 = 36.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Common spacing values
  static const double spacingXSmall = spacing8;
  static const double spacingSmall = spacing12;
  static const double spacingMedium = spacing16;
  static const double spacingLarge = spacing24;
  static const double spacingXLarge = spacing32;

  // ─────────────────────────────────────────────────────────────────────
  // BORDER RADIUS
  // ─────────────────────────────────────────────────────────────────────

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircle = 28.0;

  // ─────────────────────────────────────────────────────────────────────
  // ELEVATION / SHADOWS
  // ─────────────────────────────────────────────────────────────────────

  static const double elevationNone = 0.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 12.0;

  static const shadowSmall = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 2.0,
    offset: Offset(0, 1),
  );

  static const shadowMedium = BoxShadow(
    color: Color(0x24000000),
    blurRadius: 4.0,
    offset: Offset(0, 2),
  );

  static const shadowLarge = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 8.0,
    offset: Offset(0, 4),
  );

  static const shadowXLarge = BoxShadow(
    color: Color(0x3D000000),
    blurRadius: 16.0,
    offset: Offset(0, 8),
  );

  // ─────────────────────────────────────────────────────────────────────
  // ANIMATION DURATIONS
  // ─────────────────────────────────────────────────────────────────────

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationXSlow = Duration(milliseconds: 600);
  static const Duration durationXXSlow = Duration(milliseconds: 800);

  // ─────────────────────────────────────────────────────────────────────
  // ANIMATION CURVES
  // ─────────────────────────────────────────────────────────────────────

  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveLinear = Curves.linear;
  static const Curve curveBounce = Curves.bounceOut;

  // ─────────────────────────────────────────────────────────────────────
  // DIMENSIONS
  // ─────────────────────────────────────────────────────────────────────

  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double floatingActionButtonRadius = 56.0;

  static const double imageAspectRatioSquare = 1.0;
  static const double imageAspectRatioWide = 16.0 / 9.0;
  static const double imageAspectRatioPortrait = 3.0 / 4.0;

  // ─────────────────────────────────────────────────────────────────────
  // OPACITY VALUES
  // ─────────────────────────────────────────────────────────────────────

  static const double opacityFull = 1.0;
  static const double opacityHigh = 0.87;
  static const double opacityMedium = 0.60;
  static const double opacityLow = 0.38;
  static const double opacityDisabled = 0.38;
  static const double opacityHover = 0.04;
  static const double opacityFocus = 0.12;
}

/// Text styles using design tokens
class DesignTextStyles {
  // ─────────────────────────────────────────────────────────────────────
  // HEADLINES
  // ─────────────────────────────────────────────────────────────────────

  static const TextStyle headline1 = TextStyle(
    fontSize: DesignTokens.fontSizeHeadline1,
    fontWeight: DesignTokens.fontWeightBold,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: DesignTokens.fontSizeHeadline2,
    fontWeight: DesignTokens.fontWeightBold,
    letterSpacing: -0.25,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: DesignTokens.fontSizeHeadline3,
    fontWeight: DesignTokens.fontWeightBold,
  );

  // ─────────────────────────────────────────────────────────────────────
  // TITLES
  // ─────────────────────────────────────────────────────────────────────

  static const TextStyle title1 = TextStyle(
    fontSize: DesignTokens.fontSizeTitle1,
    fontWeight: DesignTokens.fontWeightBold,
    letterSpacing: 0.15,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: DesignTokens.fontSizeTitle2,
    fontWeight: DesignTokens.fontWeightSemiBold,
    letterSpacing: 0.1,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: DesignTokens.fontSizeTitle2,
    fontWeight: DesignTokens.fontWeightMedium,
    letterSpacing: 0.1,
  );

  // ─────────────────────────────────────────────────────────────────────
  // BODY TEXT
  // ─────────────────────────────────────────────────────────────────────

  static const TextStyle body1 = TextStyle(
    fontSize: DesignTokens.fontSizeBody1,
    fontWeight: DesignTokens.fontWeightNormal,
    letterSpacing: 0.5,
  );

  static const TextStyle body1SemiBold = TextStyle(
    fontSize: DesignTokens.fontSizeBody1,
    fontWeight: DesignTokens.fontWeightSemiBold,
    letterSpacing: 0.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: DesignTokens.fontSizeBody2,
    fontWeight: DesignTokens.fontWeightNormal,
    letterSpacing: 0.25,
  );

  static const TextStyle body2SemiBold = TextStyle(
    fontSize: DesignTokens.fontSizeBody2,
    fontWeight: DesignTokens.fontWeightSemiBold,
    letterSpacing: 0.25,
  );

  // ─────────────────────────────────────────────────────────────────────
  // CAPTIONS & SMALL TEXT
  // ─────────────────────────────────────────────────────────────────────

  static const TextStyle caption = TextStyle(
    fontSize: DesignTokens.fontSizeCaption,
    fontWeight: DesignTokens.fontWeightNormal,
    letterSpacing: 0.4,
  );

  static const TextStyle captionMedium = TextStyle(
    fontSize: DesignTokens.fontSizeCaption,
    fontWeight: DesignTokens.fontWeightMedium,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: DesignTokens.fontSizeOverline,
    fontWeight: DesignTokens.fontWeightSemiBold,
    letterSpacing: 1.5,
  );
}
