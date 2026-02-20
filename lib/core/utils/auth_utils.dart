import 'package:flutter/material.dart';

/// Auth UI Constants
class AuthUIConstants {
  static const Color primaryBlue = Color(0xFFFF0000);
  static const Color mintGreen = Color(0xFFD86767);

  // String constants
  static const String loginTitle = 'Login';
  static const String registerTitle = 'Register';
  static const String emailHint = 'Email';
  static const String passwordHint = 'Password';
  static const String confirmPasswordHint = 'Confirm Password';
  static const String nameHint = 'Name';
  static const String loginButton = 'Login';
  static const String registerButton = 'Register';
  static const String googleSignIn = 'Sign in with Google';
  static const String googleRegister = 'Register with Google';
  static const String noAccount = "Don't have an account? Register";
  static const String haveAccount = 'Already have an account? Login';
}

/// Auth UI Validators and Utilities
class AuthUIUtils {
  // ─── VALIDATORS ────────────────────────────────────────────────────────────
  static bool isValidEmail(String email) {
    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return regex.hasMatch(email);
  }

  static bool isValidPassword(String password) => password.length >= 6;

  static bool validateLogin({required String email, required String password}) {
    return isValidEmail(email) && isValidPassword(password);
  }

  static bool validateRegister({
    required String name,
    required String email,
    required String password,
    required String confirm,
  }) {
    return name.isNotEmpty &&
        isValidEmail(email) &&
        isValidPassword(password) &&
        password == confirm;
  }

  // ─── INPUT DECORATOR ────────────────────────────────────────────────────────
  static InputDecoration buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    bool obscure = false,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: AuthUIConstants.mintGreen),
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: AuthUIConstants.mintGreen.withOpacity(0.1),
    );
  }

  // ─── ELEVATED BUTTON STYLE ──────────────────────────────────────────────────
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AuthUIConstants.primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  static ButtonStyle secondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
