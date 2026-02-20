import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service layer for GoogleMapPage - Location and routing operations
class MapService {
  static const String googleApiKey = 'AIzaSyAYFRlXlNKavwP1G4ZcvD7lzI5jfXI6zfk';
  static final PolylinePoints _polylinePoints = PolylinePoints();

  // ─── INITIALIZE LOCATION ─────────────────────────────────────────────────────
  static Future<LatLng?> initLocation() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  // ─── CALCULATE DISTANCE ──────────────────────────────────────────────────────
  static double calculateDistance(LatLng current, LatLng destination) {
    return Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  // ─── CALCULATE ETA ───────────────────────────────────────────────────────────
  static Duration calculateETA(double distanceInMeters) {
    // Assume 50 km/h average speed
    final seconds = (distanceInMeters / (50 * 1000 / 3600)).round();
    return Duration(seconds: seconds);
  }

  // ─── GET TODAY'S OPENING HOURS ───────────────────────────────────────────────
  static String getTodayOpeningHours(Map<String, dynamic>? openingHours) {
    if (openingHours == null) {
      return 'Hours not available';
    }

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final todayKey = weekdays[DateTime.now().weekday - 1];
    final todayHours = openingHours[todayKey] as Map?;

    if (todayHours != null &&
        todayHours['open'] != null &&
        todayHours['close'] != null) {
      return '${todayHours['open']} - ${todayHours['close']}';
    }
    return 'Closed today';
  }

  // ─── DRAW ROUTE ──────────────────────────────────────────────────────────────
  static Future<List<LatLng>> getRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
        googleApiKey: googleApiKey,
      );

      if (result.points.isEmpty) {
        return [];
      }

      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
