import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized location utilities
/// Consolidates _extractLatLng and other location operations that were duplicated
class LocationUtils {
  // ─────────────────────────────────────────────────────────────────────
  // LATLNG EXTRACTION
  // ─────────────────────────────────────────────────────────────────────

  /// Extract LatLng from various location data formats
  /// Supports GeoPoint, Map {lat, lng}, and dynamic types
  static LatLng? extractLatLng(dynamic rawLocation) {
    if (rawLocation == null) return null;

    // Handle GeoPoint (Firestore native type)
    if (rawLocation is GeoPoint) {
      return LatLng(rawLocation.latitude, rawLocation.longitude);
    }

    // Handle Map with lat/lng keys
    if (rawLocation is Map) {
      final lat = rawLocation['lat'];
      final lng = rawLocation['lng'];
      if (lat != null && lng != null) {
        return LatLng((lat as num).toDouble(), (lng as num).toDouble());
      }
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // LATLNG CONVERSION
  // ─────────────────────────────────────────────────────────────────────

  /// Convert LatLng to GeoPoint for Firestore storage
  static GeoPoint latLngToGeoPoint(LatLng latLng) {
    return GeoPoint(latLng.latitude, latLng.longitude);
  }

  /// Convert LatLng to Map for flexible storage
  static Map<String, double> latLngToMap(LatLng latLng) {
    return {'lat': latLng.latitude, 'lng': latLng.longitude};
  }

  /// Convert GeoPoint to LatLng
  static LatLng geoPointToLatLng(GeoPoint geoPoint) {
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  /// Convert Map to LatLng
  static LatLng? mapToLatLng(Map<String, dynamic>? map) {
    if (map == null) return null;
    final lat = map['lat'];
    final lng = map['lng'];
    if (lat != null && lng != null) {
      return LatLng((lat as num).toDouble(), (lng as num).toDouble());
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // LOCATION VALIDATION
  // ─────────────────────────────────────────────────────────────────────

  /// Check if location is valid
  static bool isValidLocation(dynamic location) {
    return extractLatLng(location) != null;
  }

  /// Check if LatLng is within valid geographic bounds
  static bool isValidLatLng(LatLng latLng) {
    return latLng.latitude >= -90 &&
        latLng.latitude <= 90 &&
        latLng.longitude >= -180 &&
        latLng.longitude <= 180;
  }

  // ─────────────────────────────────────────────────────────────────────
  // DISTANCE CALCULATIONS
  // ─────────────────────────────────────────────────────────────────────

  /// Calculate distance between two LatLng points in meters (Haversine formula)
  static double calculateDistance(LatLng point1, LatLng point2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final dLng = _degreesToRadians(point2.longitude - point1.longitude);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;
    return distance * 1000; // Return in meters
  }

  /// Calculate distance between two LatLng points in kilometers
  static double calculateDistanceKm(LatLng point1, LatLng point2) {
    return calculateDistance(point1, point2) / 1000;
  }

  // ─────────────────────────────────────────────────────────────────────
  // BEARING CALCULATIONS
  // ─────────────────────────────────────────────────────────────────────

  /// Calculate bearing (direction) between two LatLng points in degrees
  static double calculateBearing(LatLng point1, LatLng point2) {
    final lat1 = _degreesToRadians(point1.latitude);
    final lat2 = _degreesToRadians(point2.latitude);
    final dLng = _degreesToRadians(point2.longitude - point1.longitude);

    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x);

    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  // ─────────────────────────────────────────────────────────────────────
  // LOCATION BOUNDS
  // ─────────────────────────────────────────────────────────────────────

  /// Check if location is within a radius of another location
  static bool isWithinRadius(LatLng center, LatLng point, double radiusKm) {
    final distance = calculateDistanceKm(center, point);
    return distance <= radiusKm;
  }

  /// Get the bounding box (bounds) for a location with given radius
  /// Returns {minLat, maxLat, minLng, maxLng}
  static Map<String, double> getBounds(LatLng center, double radiusKm) {
    const earthRadiusKm = 6371.0;

    final latOffset = (radiusKm / earthRadiusKm) * (180 / 3.14159265359);
    final lngOffset = latOffset / cos(_degreesToRadians(center.latitude));

    return {
      'minLat': center.latitude - latOffset,
      'maxLat': center.latitude + latOffset,
      'minLng': center.longitude - lngOffset,
      'maxLng': center.longitude + lngOffset,
    };
  }

  // ─────────────────────────────────────────────────────────────────────
  // HELPER FUNCTIONS
  // ─────────────────────────────────────────────────────────────────────

  static double _degreesToRadians(double degrees) {
    return degrees * 3.14159265359 / 180.0;
  }

  static double _radiansToDegrees(double radians) {
    return radians * 180.0 / 3.14159265359;
  }

  static double sin(double radians) {
    return math.sin(radians);
  }

  static double cos(double radians) {
    return math.cos(radians);
  }

  static double atan2(double y, double x) {
    return math.atan2(y, x);
  }

  static double sqrt(double value) {
    return math.sqrt(value);
  }

  // ─────────────────────────────────────────────────────────────────────
  // LOCATION FORMATTING
  // ─────────────────────────────────────────────────────────────────────

  /// Format LatLng as a readable string
  static String formatLatLng(LatLng latLng) {
    return '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
  }

  /// Format distance in appropriate units (meters or kilometers)
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}
