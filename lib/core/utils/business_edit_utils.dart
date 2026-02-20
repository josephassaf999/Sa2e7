import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// UI utilities and constants for BusinessEditPage
class BusinessEditUIConstants {
  static const Color primaryRed = Color(0xFFF63C3C);

  // String constants
  static const String appTitle = 'Edit Business';
  static const String basicInfoLabel = 'Basic Info';
  static const String businessNameLabel = 'Business Name';
  static const String descriptionLabel = 'Description';
  static const String phoneLabel = 'Phone Number';
  static const String instagramLabel = 'Instagram Link (optional)';
  static const String menuLabel = 'Menu Link (optional)';
  static const String categoryLabel = 'Category';
  static const String openingHoursLabel = 'Opening Hours';
  static const String locationLabel = 'Location';
  static const String imagesLabel = 'Images';
  static const String addImagesLabel = 'Add Images';
  static const String saveChangesLabel = 'Save Changes';
  static const String successMessage = 'Business updated successfully!';
  static const String errorMessage =
      'Please fill all required fields and set a location.';
  static const String adjustMapMessage =
      'Tap the map or drag the pin to adjust.';

  // Categories
  static const List<String> categories = [
    'All',
    'Night Life',
    'Historical',
    'Beach',
    'Food',
    'Cave',
  ];

  // Weekdays
  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Default location
  static const double defaultLat = 33.8938;
  static const double defaultLng = 35.5018;
  static const String defaultCategory = 'All';
}

/// UI helpers for BusinessEditPage
class BusinessEditUIUtils {
  // ─── INPUT DECORATION ────────────────────────────────────────────────────────
  static InputDecoration inputDecoration(String label, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.red.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      );

  // ─── SECTION LABEL ───────────────────────────────────────────────────────────
  static Widget sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: BusinessEditUIConstants.primaryRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ─── FORMAT TIME ──────────────────────────────────────────────────────────────
  static String formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // ─── PARSE TIME ───────────────────────────────────────────────────────────────
  static TimeOfDay? parseTime(dynamic raw) {
    if (raw == null || raw.toString() == '--:--') {
      return null;
    }
    final parts = raw.toString().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  // ─── INITIALIZE OPENING HOURS ────────────────────────────────────────────────
  static Map<String, Map<String, TimeOfDay?>> initializeOpeningHours() {
    return {
      'Monday': {'open': null, 'close': null},
      'Tuesday': {'open': null, 'close': null},
      'Wednesday': {'open': null, 'close': null},
      'Thursday': {'open': null, 'close': null},
      'Friday': {'open': null, 'close': null},
      'Saturday': {'open': null, 'close': null},
      'Sunday': {'open': null, 'close': null},
    };
  }

  // ─── CONVERT OPENING HOURS FOR SAVING ────────────────────────────────────────
  static Map<String, Map<String, String?>> convertOpeningHours(
    Map<String, Map<String, TimeOfDay?>> openingHours,
  ) {
    Map<String, Map<String, String?>> hoursToSave = {};
    for (final entry in openingHours.entries) {
      hoursToSave[entry.key] = {
        'open': formatTime(entry.value['open']),
        'close': formatTime(entry.value['close']),
      };
    }
    return hoursToSave;
  }

  // ─── PARSE LOCATION ───────────────────────────────────────────────────────────
  static LatLng parseLocation(dynamic rawLoc) {
    // Handle both GeoPoint and Map {lat,lng}
    if (rawLoc is GeoPoint) {
      return LatLng(rawLoc.latitude, rawLoc.longitude);
    } else if (rawLoc is Map &&
        rawLoc['lat'] != null &&
        rawLoc['lng'] != null) {
      return LatLng(
        (rawLoc['lat'] as num).toDouble(),
        (rawLoc['lng'] as num).toDouble(),
      );
    }
    return const LatLng(
      BusinessEditUIConstants.defaultLat,
      BusinessEditUIConstants.defaultLng,
    );
  }
}
