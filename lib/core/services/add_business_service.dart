import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sa2e7/firebase/firebase_config.dart';

/// Service layer for AddBusinessPage - Firebase operations
class AddBusinessService {
  // ─── UPLOAD IMAGES ───────────────────────────────────────────────────────────
  static Future<List<String>> uploadImages(List<File> selectedImages) async {
    final List<String> uploadedImageUrls = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Please login to upload images.');
    }

    final storage = FirebaseStorage.instanceFor(
      bucket: FirebaseConfig.storageBucket,
    );

    for (int i = 0; i < selectedImages.length; i++) {
      final file = selectedImages[i];
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

      final ref = storage
          .ref()
          .child('businesses')
          .child(user.uid)
          .child(fileName);

      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();
      uploadedImageUrls.add(downloadUrl);
    }

    return uploadedImageUrls;
  }

  // ─── SAVE BUSINESS ───────────────────────────────────────────────────────────
  static Future<void> saveBusiness({
    required String name,
    required String description,
    required String phone,
    required String instagram,
    required String menuLink,
    required String category,
    required LatLng location,
    required List<String> imageUrls,
    required Map<String, Map<String, String?>> openingHours,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot save business.');
    }

    await FirebaseFirestore.instance.collection('businesses').add({
      'name': name.trim(),
      'description': description.trim(),
      'phone': phone.trim(),
      'instagram': instagram.trim(),
      'menuLink': menuLink.trim(),
      'category': category,
      'location': GeoPoint(location.latitude, location.longitude),
      'images': imageUrls,
      'openingHours': openingHours,
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'avgRating': 0.0,
      'numRatings': 0,
    });
  }
}
