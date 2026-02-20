import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'business_change_detection_service.dart';

/// Service layer for BusinessEditPage - Firebase and image operations
class BusinessEditService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // ─── LOAD BUSINESS ───────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> loadBusiness(String businessId) async {
    try {
      final doc =
          await _firestore.collection('businesses').doc(businessId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  // ─── UPLOAD NEW IMAGES ───────────────────────────────────────────────────────
  static Future<List<String>> uploadNewImages(
    String businessId,
    List<XFile> newImages,
  ) async {
    final List<String> urls = [];
    for (final image in newImages) {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final ref = _storage.ref().child(
          'business_images/$businessId/$fileName',
        );
        await ref.putFile(File(image.path));
        urls.add(await ref.getDownloadURL());
      } catch (e) {
        continue;
      }
    }
    return urls;
  }

  // ─── SAVE BUSINESS ───────────────────────────────────────────────────────────
  static Future<void> saveBusiness({
    required String businessId,
    required String name,
    required String description,
    required String phone,
    required String instagram,
    required String menuLink,
    required String category,
    required LatLng location,
    required List<String> allImages,
    required Map<String, Map<String, String?>> openingHours,
  }) async {
    try {
      // Load previous opening hours to detect changes
      final previousDoc =
          await _firestore.collection('businesses').doc(businessId).get();
      final previousOpeningHours =
          previousDoc.data() is Map
              ? (previousDoc.data() as Map)['openingHours'] ?? {}
              : {};

      // Check if hours changed
      bool hoursChanged = false;
      List<String> changedDays = [];

      if (previousOpeningHours.isNotEmpty && openingHours.isNotEmpty) {
        for (var day in openingHours.keys) {
          final prevHours = previousOpeningHours[day];
          final newHours = openingHours[day];

          if (prevHours != newHours) {
            hoursChanged = true;
            changedDays.add(day);
          }
        }
      }

      // Update business in Firestore
      await _firestore.collection('businesses').doc(businessId).update({
        'name': name.trim(),
        'description': description.trim(),
        'phone': phone.trim(),
        'instagram': instagram.trim(),
        'menuLink': menuLink.trim(),
        'category': category,
        'location': GeoPoint(location.latitude, location.longitude),
        'images': allImages,
        'openingHours': openingHours,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If hours changed, track history and notify users
      if (hoursChanged && changedDays.isNotEmpty) {
        // Add to hours history
        await _firestore.collection('businesses').doc(businessId).update({
          'hoursHistory': FieldValue.arrayUnion([
            {
              'timestamp': FieldValue.serverTimestamp(),
              'previousHours': previousOpeningHours,
              'changedBy': 'business_owner', // In production, get actual userId
            },
          ]),
        });

        // Notify users who favorited this business
        final changeDetectionService = BusinessChangeDetectionService();
        await changeDetectionService.notifyUsersAboutHourChange(
          businessId,
          changedDays,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
