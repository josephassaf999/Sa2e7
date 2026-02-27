import 'package:flutter/material.dart';

/// Centralized form validation utilities
/// Replaces scattered validators across auth_utils.dart and other files
class FormValidators {
  // ─────────────────────────────────────────────────────────────────────
  // EMAIL VALIDATION
  // ─────────────────────────────────────────────────────────────────────

  /// Validate email format
  static bool isValidEmail(String email) {
    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return regex.hasMatch(email);
  }

  /// Email field validator for TextFormField
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // PASSWORD VALIDATION
  // ─────────────────────────────────────────────────────────────────────

  /// Validate password strength (minimum 6 characters)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Password field validator for TextFormField
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(value)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Confirm password validator (checks if matches another password)
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // NAME VALIDATION
  // ─────────────────────────────────────────────────────────────────────

  /// Validate name (not empty, reasonable length)
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  /// Name field validator for TextFormField
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(value)) {
      return 'Please enter a valid name (at least 2 characters)';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // PHONE NUMBER VALIDATION
  // ─────────────────────────────────────────────────────────────────────

  /// Validate phone number (basic format check)
  static bool isValidPhoneNumber(String phone) {
    // Remove spaces and special characters for validation
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 7; // At least 7 digits
  }

  /// Phone number field validator for TextFormField
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // URL VALIDATION
  // ─────────────────────────────────────────────────────────────────────

  /// Validate URL format
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  /// URL field validator for TextFormField
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    if (!isValidUrl(value)) {
      return 'Please enter a valid URL (must start with http:// or https://)';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // GENERIC VALIDATION
  // ─────────────────────────────────────────────────────────────────────

  /// Validate that a field is not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value == null) return null;
    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // LOGIN VALIDATION (BATCH)
  // ─────────────────────────────────────────────────────────────────────

  /// Validate login credentials (returns error message or null if valid)
  static String? validateLoginForm({
    required String email,
    required String password,
  }) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    return null; // All valid
  }

  // ─────────────────────────────────────────────────────────────────────
  // REGISTRATION VALIDATION (BATCH)
  // ─────────────────────────────────────────────────────────────────────

  /// Validate registration form (returns error message or null if valid)
  static String? validateRegistrationForm({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (name.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(name)) {
      return 'Please enter a valid name';
    }
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(password)) {
      return 'Password must be at least 6 characters';
    }
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null; // All valid
  }

  // ─────────────────────────────────────────────────────────────────────
  // BUSINESS VALIDATION (BATCH)
  // ─────────────────────────────────────────────────────────────────────

  /// Validate business form (returns error message or null if valid)
  static String? validateBusinessForm({
    required String businessName,
    required String category,
    required String phoneNumber,
    bool validatePhone = true,
  }) {
    if (businessName.isEmpty) {
      return 'Business name is required';
    }
    if (!isValidName(businessName)) {
      return 'Please enter a valid business name';
    }
    if (category.isEmpty) {
      return 'Please select a business category';
    }
    if (validatePhone) {
      if (phoneNumber.isEmpty) {
        return 'Phone number is required';
      }
      if (!isValidPhoneNumber(phoneNumber)) {
        return 'Please enter a valid phone number';
      }
    }
    return null; // All valid
  }
}
