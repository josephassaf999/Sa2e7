import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// App Theme Configuration for Sa2e7
/// Provides light and dark theme using Material Design 3
class AppTheme {
  // ─────────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryRed,
        brightness: Brightness.light,
      ).copyWith(
        primary: DesignTokens.primaryRed,
        onPrimary: DesignTokens.textInvertedLight,
        secondary: DesignTokens.primaryGreen,
        onSecondary: DesignTokens.textInvertedLight,
        error: DesignTokens.errorColor,
        onError: Colors.white,
        surface: DesignTokens.surfaceLight,
        onSurface: DesignTokens.textPrimaryLight,
      ),
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.primaryRed,
        foregroundColor: DesignTokens.textInvertedLight,
        elevation: DesignTokens.elevationSmall,
        centerTitle: true,
        titleTextStyle: DesignTextStyles.title1.copyWith(
          color: DesignTokens.textInvertedLight,
        ),
        iconTheme: const IconThemeData(color: DesignTokens.textInvertedLight),
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DesignTokens.primaryRed,
        foregroundColor: DesignTokens.textInvertedLight,
        elevation: DesignTokens.elevationLarge,
      ),
      // Card Theme
      cardTheme: CardTheme(
        color: DesignTokens.surfaceLight,
        elevation: DesignTokens.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
      ),
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryRed,
          foregroundColor: DesignTokens.textInvertedLight,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing24,
            vertical: DesignTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          elevation: DesignTokens.elevationSmall,
        ),
      ),
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryRed,
          side: const BorderSide(color: DesignTokens.primaryRed, width: 2.0),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing24,
            vertical: DesignTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
        ),
      ),
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.primaryRed,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: DesignTokens.spacing8,
          ),
        ),
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surfaceVariantLight,
        contentPadding: const EdgeInsets.all(DesignTokens.spacing16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(
            color: DesignTokens.primaryRed,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(
            color: DesignTokens.errorColor,
            width: 2.0,
          ),
        ),
        hintStyle: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textSecondaryLight,
        ),
        labelStyle: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textSecondaryLight,
        ),
      ),
      // Text Theme
      textTheme: TextTheme(
        displayLarge: DesignTextStyles.headline1.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        displayMedium: DesignTextStyles.headline2.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        displaySmall: DesignTextStyles.headline3.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        headlineMedium: DesignTextStyles.title1.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        headlineSmall: DesignTextStyles.title2.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        titleLarge: DesignTextStyles.title1.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        titleMedium: DesignTextStyles.title2.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        titleSmall: DesignTextStyles.titleMedium.copyWith(
          color: DesignTokens.textSecondaryLight,
        ),
        bodyLarge: DesignTextStyles.body1.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        bodyMedium: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        bodySmall: DesignTextStyles.caption.copyWith(
          color: DesignTokens.textSecondaryLight,
        ),
        labelLarge: DesignTextStyles.title2.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        labelMedium: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        labelSmall: DesignTextStyles.caption.copyWith(
          color: DesignTokens.textSecondaryLight,
        ),
      ),
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfaceLight,
        selectedItemColor: DesignTokens.primaryRed,
        unselectedItemColor: DesignTokens.textSecondaryLight,
        elevation: DesignTokens.elevationMedium,
      ),
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: DesignTokens.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        elevation: DesignTokens.elevationLarge,
      ),
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.surfaceVariantLight,
        contentTextStyle: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textPrimaryLight,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryRed,
        brightness: Brightness.dark,
      ).copyWith(
        primary: DesignTokens.primaryRed,
        onPrimary: DesignTokens.textInvertedDark,
        secondary: DesignTokens.primaryGreenLight,
        onSecondary: DesignTokens.textInvertedDark,
        error: DesignTokens.errorColor,
        onError: Colors.black,
        surface: DesignTokens.surfaceDark,
        onSurface: DesignTokens.textPrimaryDark,
      ),
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.primaryRed,
        foregroundColor: DesignTokens.textInvertedDark,
        elevation: DesignTokens.elevationSmall,
        centerTitle: true,
        titleTextStyle: DesignTextStyles.title1.copyWith(
          color: DesignTokens.textInvertedDark,
        ),
        iconTheme: const IconThemeData(color: DesignTokens.textInvertedDark),
      ),
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DesignTokens.primaryRed,
        foregroundColor: DesignTokens.textInvertedDark,
        elevation: DesignTokens.elevationLarge,
      ),
      // Card Theme
      cardTheme: CardTheme(
        color: DesignTokens.surfaceVariantDark,
        elevation: DesignTokens.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
      ),
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryRed,
          foregroundColor: DesignTokens.textInvertedDark,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing24,
            vertical: DesignTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          elevation: DesignTokens.elevationSmall,
        ),
      ),
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryRed,
          side: const BorderSide(color: DesignTokens.primaryRed, width: 2.0),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing24,
            vertical: DesignTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
        ),
      ),
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.primaryRed,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: DesignTokens.spacing8,
          ),
        ),
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surfaceVariantDark,
        contentPadding: const EdgeInsets.all(DesignTokens.spacing16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(
            color: DesignTokens.primaryRed,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(color: DesignTokens.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: const BorderSide(
            color: DesignTokens.errorColor,
            width: 2.0,
          ),
        ),
        hintStyle: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textSecondaryDark,
        ),
        labelStyle: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textSecondaryDark,
        ),
      ),
      // Text Theme
      textTheme: TextTheme(
        displayLarge: DesignTextStyles.headline1.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        displayMedium: DesignTextStyles.headline2.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        displaySmall: DesignTextStyles.headline3.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        headlineMedium: DesignTextStyles.title1.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        headlineSmall: DesignTextStyles.title2.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        titleLarge: DesignTextStyles.title1.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        titleMedium: DesignTextStyles.title2.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        titleSmall: DesignTextStyles.titleMedium.copyWith(
          color: DesignTokens.textSecondaryDark,
        ),
        bodyLarge: DesignTextStyles.body1.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        bodyMedium: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        bodySmall: DesignTextStyles.caption.copyWith(
          color: DesignTokens.textSecondaryDark,
        ),
        labelLarge: DesignTextStyles.title2.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        labelMedium: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        labelSmall: DesignTextStyles.caption.copyWith(
          color: DesignTokens.textSecondaryDark,
        ),
      ),
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfaceDark,
        selectedItemColor: DesignTokens.primaryRed,
        unselectedItemColor: DesignTokens.textSecondaryDark,
        elevation: DesignTokens.elevationMedium,
      ),
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: DesignTokens.surfaceVariantDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        elevation: DesignTokens.elevationLarge,
      ),
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.surfaceVariantDark,
        contentTextStyle: DesignTextStyles.body2.copyWith(
          color: DesignTokens.textPrimaryDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        ),
      ),
    );
  }
}
