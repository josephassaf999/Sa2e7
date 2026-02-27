import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized service for managing user favorites
/// Eliminates duplication across HomeService and BusinessService
class FavoritesService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Get the current user's reference in Firestore
  static DocumentReference<Map<String, dynamic>> _getUserRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Please login to manage favorites.');
    }
    return _firestore.collection('Users').doc(user.uid);
  }

  /// Load all favorites for the current user
  static Future<Set<String>> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final doc = await _getUserRef().get();
      final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
      return favorites.toSet();
    } catch (e) {
      return {};
    }
  }

  /// Check if a business is in the current user's favorites
  static Future<bool> isFavorite(String businessId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _getUserRef().get();
      final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
      return favorites.contains(businessId);
    } catch (e) {
      return false;
    }
  }

  /// Add a business to favorites
  static Future<void> addFavorite(String businessId) async {
    try {
      await _getUserRef().update({
        'favorites': FieldValue.arrayUnion([businessId]),
      });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  /// Remove a business from favorites
  static Future<void> removeFavorite(String businessId) async {
    try {
      await _getUserRef().update({
        'favorites': FieldValue.arrayRemove([businessId]),
      });
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  /// Toggle favorite status (add if not present, remove if present)
  /// Uses atomic FieldValue operations to minimize reads
  static Future<void> toggleFavorite(String businessId) async {
    final isFav = await isFavorite(businessId);

    if (isFav) {
      await removeFavorite(businessId);
    } else {
      await addFavorite(businessId);
    }
  }

  /// Clear all favorites for the current user (use with caution)
  static Future<void> clearAllFavorites() async {
    try {
      await _getUserRef().update({'favorites': []});
    } catch (e) {
      throw Exception('Failed to clear favorites: $e');
    }
  }

  /// Get count of user's favorites
  static Future<int> getFavoritesCount() async {
    try {
      final favorites = await loadFavorites();
      return favorites.length;
    } catch (e) {
      return 0;
    }
  }
}
