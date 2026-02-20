import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get();
      final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
      return favorites.toSet();
    } catch (e) {
      return {};
    }
  }

  // ─── TOGGLE FAVORITE ──────────────────────────────────────────────────────────
  static Future<void> toggleFavorite(String businessId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'User not logged in';

    final userRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid);

    // Get current favorites to check state
    final doc = await userRef.get();
    final currentFavorites = List<String>.from(doc.data()?['favorites'] ?? []);

    if (currentFavorites.contains(businessId)) {
      // Remove from favorites
      await userRef.update({
        'favorites': FieldValue.arrayRemove([businessId]),
      });
    } else {
      // Add to favorites
      await userRef.update({
        'favorites': FieldValue.arrayUnion([businessId]),
      });
    }
  }

  // ─── REFRESH BUSINESSES ──────────────────────────────────────────────────────
  static Future<void> refreshBusinesses() async {
    // Trigger a Firestore fetch to refresh data
    await FirebaseFirestore.instance.collection('businesses').limit(1).get();
  }
}
