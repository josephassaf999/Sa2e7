import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sa2e7/core/utils/location_utils.dart';
import 'favorites_service.dart';

/// Service class handling all business-related Firebase operations
class BusinessService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Load business data and related info from Firestore
  static Future<Map<String, dynamic>?> loadBusiness(String businessId) async {
    try {
      final doc =
          await _firestore.collection('businesses').doc(businessId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance from user to business location
  static Future<double?> calculateDistance(dynamic rawLocation) async {
    final businessLatLng = LocationUtils.extractLatLng(rawLocation);
    if (businessLatLng == null) return null;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final meters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        businessLatLng.latitude,
        businessLatLng.longitude,
      );
      return meters / 1000;
    } catch (e) {
      return null;
    }
  }

  /// Check if business is in user's favorites
  static Future<bool> checkIfFavorite(String businessId) async {
    return FavoritesService.isFavorite(businessId);
  }

  /// Toggle favorite status for a business
  static Future<void> toggleFavorite(String businessId) async {
    return FavoritesService.toggleFavorite(businessId);
  }

  /// Launch external URL
  static Future<bool> launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Share business details
  static Future<void> shareBusiness(String name, String description) async {
    await Share.share(
      '📍 Check out $name on Sa2e7!\n\n$description\n\nDownload the Sa2e7 app to explore Lebanon.',
      subject: name,
    );
  }

  /// Submit a review for the business
  static Future<void> submitReview(
    String businessId,
    double rating,
    String text,
  ) async {
    if (text.trim().isEmpty) {
      throw Exception('Review text cannot be empty. Please write a review.');
    }

    final user = _auth.currentUser;
    if (user == null)
      throw Exception('User not logged in. Please login to submit a review.');

    final userName =
        (user.displayName?.isNotEmpty ?? false)
            ? user.displayName!
            : (user.email?.split('@').first ?? 'Anonymous');

    try {
      final businessRef = _firestore.collection('businesses').doc(businessId);
      final newReviewRef = businessRef.collection('reviews').doc();

      await _firestore.runTransaction((transaction) async {
        final businessSnapshot = await transaction.get(businessRef);
        if (!businessSnapshot.exists) throw Exception("Business not found");

        final data = businessSnapshot.data() as Map<String, dynamic>;
        final numRatings = (data['numRatings'] ?? 0) + 1;
        final avgRating =
            ((data['avgRating'] ?? 0.0) * (numRatings - 1) + rating) /
            numRatings;

        transaction.update(businessRef, {
          'numRatings': numRatings,
          'avgRating': avgRating,
        });

        transaction.set(newReviewRef, {
          'rating': rating,
          'text': text.trim(),
          'userName': userName,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception("Failed to submit review: $e");
    }
  }
}
