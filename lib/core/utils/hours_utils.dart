import 'package:flutter/material.dart';

/// Consolidates all opening hours parsing, formatting, and conversion logic
/// Eliminates duplication across add_business_utils and business_edit_utils
class HoursUtils {
  // Days of week for consistent ordering
  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Formats TimeOfDay object to "HH:MM" string format
  /// Returns "--:--" if timeOfDay is null
  static String formatTime(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return "--:--";
    final hours = timeOfDay.hour.toString().padLeft(2, '0');
    final minutes = timeOfDay.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  /// Parses "HH:MM" string format back to TimeOfDay object
  /// Returns null if parseString is null or invalid
  static TimeOfDay? parseTime(dynamic parseString) {
    if (parseString == null) return null;
    try {
      final parts = parseString.toString().split(':');
      if (parts.length != 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  /// Initializes opening hours structure with all 7 days
  /// Each day has empty 'start' and 'end' TimeOfDay values
  /// Used when creating new business
  static Map<String, Map<String, TimeOfDay?>> initializeOpeningHours() {
    final hours = <String, Map<String, TimeOfDay?>>{};
    for (final day in daysOfWeek) {
      hours[day] = {'start': null, 'end': null};
    }
    return hours;
  }

  /// Converts TimeOfDay-based hours map to String-based map for Firebase storage
  /// Firebase stores hours as strings "HH:MM" since Firestore doesn't support TimeOfDay
  static Map<String, Map<String, String?>> convertOpeningHours(
    Map<String, Map<String, TimeOfDay?>> timeOfDayHours,
  ) {
    final stringHours = <String, Map<String, String?>>{};
    for (final entry in timeOfDayHours.entries) {
      final day = entry.key;
      final dayHours = entry.value;
      stringHours[day] = {
        'start': formatTime(dayHours['start']),
        'end': formatTime(dayHours['end']),
      };
    }
    return stringHours;
  }

  /// Converts String-based hours map (from Firebase) to TimeOfDay-based map
  /// Reverse of convertOpeningHours() - used when loading existing business
  static Map<String, Map<String, TimeOfDay?>> parseOpeningHours(
    Map<String, dynamic> stringHours,
  ) {
    final timeOfDayHours = <String, Map<String, TimeOfDay?>>{};
    for (final entry in stringHours.entries) {
      final day = entry.key;
      final dayHours = entry.value as Map<String, dynamic>?;
      timeOfDayHours[day] = {
        'start': parseTime(dayHours?['start']),
        'end': parseTime(dayHours?['end']),
      };
    }
    return timeOfDayHours;
  }

  /// Gets today's opening hours formatted as "HH:MM - HH:MM" string
  /// Used in map markers and quick display
  /// Returns "Closed" if hours not available for today
  static String getTodayOpeningHours(Map<String, dynamic>? openingHours) {
    if (openingHours == null) return "Closed";

    final now = DateTime.now();
    final dayIndex = now.weekday; // 1 = Monday, 7 = Sunday
    final todayKey =
        daysOfWeek[dayIndex == 7 ? 6 : dayIndex - 1]; // Adjust for 0-indexing

    final todayHours = openingHours[todayKey] as Map<String, dynamic>?;
    if (todayHours == null) return "Closed";

    final startStr = todayHours['start']?.toString() ?? '';
    final endStr = todayHours['end']?.toString() ?? '';

    if (startStr.isEmpty || endStr.isEmpty) return "Closed";
    return "$startStr - $endStr";
  }

  /// Checks if hours are set for a specific day
  static bool hasHoursForDay(Map<String, dynamic>? openingHours, String day) {
    if (openingHours == null) return false;
    final dayHours = openingHours[day] as Map<String, dynamic>?;
    if (dayHours == null) return false;
    final start = dayHours['start']?.toString() ?? '';
    final end = dayHours['end']?.toString() ?? '';
    return start.isNotEmpty && end.isNotEmpty;
  }

  /// Gets business status (Open/Closed) based on current time
  static String getBusinessStatus(Map<String, dynamic>? openingHours) {
    if (openingHours == null) return "Closed";

    final now = DateTime.now();
    final dayIndex = now.weekday; // 1 = Monday, 7 = Sunday
    final todayKey = daysOfWeek[dayIndex == 7 ? 6 : dayIndex - 1];

    final todayHours = openingHours[todayKey] as Map<String, dynamic>?;
    if (todayHours == null) return "Closed";

    final startStr = todayHours['start']?.toString() ?? '';
    final endStr = todayHours['end']?.toString() ?? '';

    if (startStr.isEmpty || endStr.isEmpty) return "Closed";

    try {
      final startParts = startStr.split(':');
      final endParts = endStr.split(':');

      final startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
      final endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );

      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

      // Compare times
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;

      if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        return "Open";
      } else {
        return "Closed";
      }
    } catch (e) {
      return "Closed";
    }
  }

  /// Formats hours for UI display with styling
  /// Shows all days with today highlighted
  static String formatHoursForDisplay(
    Map<String, dynamic>? openingHours,
    String day,
  ) {
    if (openingHours == null) return "Closed";

    final dayHours = openingHours[day] as Map<String, dynamic>?;
    if (dayHours == null) return "Closed";

    final start = dayHours['start']?.toString() ?? '';
    final end = dayHours['end']?.toString() ?? '';

    if (start.isEmpty || end.isEmpty) return "Closed";
    return "$start - $end";
  }
}
