import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'favorites_service.dart';

/// Service layer for HomePage - Firestore and Auth operations
class HomeService {
  // ─── LOAD USER NAME ──────────────────────────────────────────────────────────
  static Future<String?> loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get();
      return doc.data()?['name'] ?? 'User';
    } catch (e) {
      return null;
    }
  }

  // ─── LOAD FAVORITES ──────────────────────────────────────────────────────────
  static Future<Set<String>> loadFavorites() async {
    return FavoritesService.loadFavorites();
  }

  // ─── TOGGLE FAVORITE ──────────────────────────────────────────────────────────
  static Future<void> toggleFavorite(String businessId) async {
    return FavoritesService.toggleFavorite(businessId);
  }

  // ─── REFRESH BUSINESSES ──────────────────────────────────────────────────────
  static Future<void> refreshBusinesses() async {
    // Trigger a Firestore fetch to refresh data
    await FirebaseFirestore.instance.collection('businesses').limit(1).get();
  }
}
