import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service layer for Businesses (YourListingsPage)
class BusinessManagementService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ─── GET USER BUSINESSES ─────────────────────────────────────────────────────
  static Stream<QuerySnapshot> getUserBusinesses() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('businesses')
        .where('ownerId', isEqualTo: userId)
        .snapshots();
  }

  // ─── DELETE BUSINESS ─────────────────────────────────────────────────────────
  static Future<void> deleteBusiness(String businessId) async {
    await _firestore.collection('businesses').doc(businessId).delete();
  }

  // ─── GET CURRENT USER ────────────────────────────────────────────────────────
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
