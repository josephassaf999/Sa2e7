import 'package:flutter/material.dart';

/// UI utilities and constants for AddBusinessPage
class AddBusinessUIConstants {
  static const Color primaryRed = Color(0xFFF63C3C);

  // String constants
  static const String appTitle = 'Add Business';
  static const String businessNameLabel = 'Business Name';
  static const String descriptionLabel = 'Description';
  static const String phoneLabel = 'Phone Number';
  static const String instagramLabel = 'Instagram Link (Optional)';
  static const String menuLabel = 'Menu Link (Optional)';
  static const String categoryLabel = 'Category';
  static const String openingHoursLabel = 'Opening Hours';
  static const String quickHoursLabel = 'Quick hours';
  static const String quickHoursHint =
      'Pick opening and closing times once, then apply them to every day.';
  static const String applyToAllDaysLabel = 'Apply to all days';
  static const String clearAllLabel = 'Clear all';
  static const String uploadImagesLabel = 'Upload Images';
  static const String addBusinessLabel = 'Add Business';

  // Categories
  static const List<String> categories = [
    "All",
    "Night Life",
    "Historical",
    "Beach",
    "Food",
    "Religious",
  ];

  // Weekdays
  static const List<String> weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  // Error/validation messages
  static const String requiredFieldError = 'Required';
  static const String fillAllFieldsError =
      'Fill all required fields, select location and upload at least one image';
  static const String businessAddedSuccess = 'Business added successfully';
}

/// UI builders for AddBusinessPage
class AddBusinessUIUtils {
  // ─── INPUT DECORATION ────────────────────────────────────────────────────────
  static InputDecoration inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.red.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );

  // ─── FORMAT TIME ──────────────────────────────────────────────────────────────
  static String formatTime(TimeOfDay? t) {
    if (t == null) return "--:--";
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  // ─── OPENING HOURS INITIALIZATION ────────────────────────────────────────────
  static Map<String, Map<String, TimeOfDay?>> initializeOpeningHours() {
    return {
      "Monday": {"open": null, "close": null},
      "Tuesday": {"open": null, "close": null},
      "Wednesday": {"open": null, "close": null},
      "Thursday": {"open": null, "close": null},
      "Friday": {"open": null, "close": null},
      "Saturday": {"open": null, "close": null},
      "Sunday": {"open": null, "close": null},
    };
  }

  // ─── OPENING HOURS TO MAP ────────────────────────────────────────────────────
  static Map<String, Map<String, String?>> convertOpeningHours(
    Map<String, Map<String, TimeOfDay?>> openingHours,
  ) {
    Map<String, Map<String, String?>> hoursToSave = {};
    openingHours.forEach((day, times) {
      hoursToSave[day] = {
        "open": times["open"] != null ? formatTime(times["open"]) : null,
        "close": times["close"] != null ? formatTime(times["close"]) : null,
      };
    });
    return hoursToSave;
  }

  static Map<String, Map<String, TimeOfDay?>> applyHoursToAllDays(
    Map<String, Map<String, TimeOfDay?>> openingHours,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  ) {
    final updatedHours = <String, Map<String, TimeOfDay?>>{};
    for (final day in AddBusinessUIConstants.weekdays) {
      updatedHours[day] = {"open": openTime, "close": closeTime};
    }
    return updatedHours;
  }

  static Map<String, Map<String, TimeOfDay?>> clearAllHours(
    Map<String, Map<String, TimeOfDay?>> openingHours,
  ) {
    final updatedHours = <String, Map<String, TimeOfDay?>>{};
    for (final day in AddBusinessUIConstants.weekdays) {
      updatedHours[day] = {"open": null, "close": null};
    }
    return updatedHours;
  }
}
