import 'package:flutter/material.dart';

/// UI constants for GoogleMapPage
class MapUIConstants {
  static const Color primaryRed = Color(0xFFF63C3C);

  // String constants
  static const String mapTitle = 'Map';
  static const String navigateLabel = 'Navigate';
  static const String callLabel = 'Call';
  static const String infoLabel = 'Info';
  static const String unableToGetRoute = 'Unable to get route';

  // Categories
  static const List<String> categories = [
    "All",
    "Night Life",
    "Historical",
    "Beach",
    "Food",
    "Cave",
  ];
}

/// UI utilities for GoogleMapPage
class MapUIUtils {
  // ─── BUILD BUSINESS INFO DATA ────────────────────────────────────────────────
  static Map<String, dynamic> buildBusinessInfo({
    required String businessId,
    required Map<String, dynamic> business,
    required double distance,
    required Duration eta,
    required String displayHours,
  }) {
    return {
      ...business,
      'id': businessId,
      'distance': distance,
      'eta': eta,
      'displayHours': displayHours,
    };
  }

  // ─── FORMAT DISTANCE ─────────────────────────────────────────────────────────
  static String formatDistance(double distanceInMeters) {
    return (distanceInMeters / 1000).toStringAsFixed(2);
  }

  // ─── GET CATEGORY BADGE COLOR ────────────────────────────────────────────────
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Night Life':
        return Colors.purple;
      case 'Historical':
        return Colors.brown;
      case 'Beach':
        return Colors.blue;
      case 'Food':
        return Colors.orange;
      case 'Cave':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
