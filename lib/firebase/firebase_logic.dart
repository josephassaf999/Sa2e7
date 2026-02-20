import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fcm_notification_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Email/Password Login
  Future<User?> login({required String email, required String password}) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Email/Password Register
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) return null;
    if (password.length < 6) return null;

    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get FCM token
    final fcmToken = await FCMNotificationHandler().getFCMToken();

    // Save user in Firestore
    await _firestore.collection('Users').doc(result.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'isBusinessOwner': false,
      'fcmToken': fcmToken,
      'fcmTokens': fcmToken.isNotEmpty ? [fcmToken] : [],
      'preferredCategories': [],
      'notificationSettings': {
        'newBusinessNotifications': true,
        'hoursChangeNotifications': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'notificationHistory': [],
    });

    return result.user;
  }

  /// Google Sign-In
  Future<User?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);

    // Get FCM token
    final fcmToken = await FCMNotificationHandler().getFCMToken();

    // Save user in Firestore if new
    final doc =
        await _firestore.collection('Users').doc(result.user!.uid).get();
    if (!doc.exists) {
      await _firestore.collection('Users').doc(result.user!.uid).set({
        'name': result.user!.displayName ?? '',
        'email': result.user!.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isBusinessOwner': false,
        'fcmToken': fcmToken,
        'fcmTokens': fcmToken.isNotEmpty ? [fcmToken] : [],
        'preferredCategories': [],
        'notificationSettings': {
          'newBusinessNotifications': true,
          'hoursChangeNotifications': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'notificationHistory': [],
      });
    }

    return result.user;
  }

  /// Promote existing user to Business Owner
  Future<void> promoteToBusinessOwner({required String name}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in.");

    final uid = user.uid;

    // Update Users collection
    await _firestore.collection('Users').doc(uid).update({
      'isBusinessOwner': true,
      'businessName':
          name, // optional, can track business later in add business page
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;
}
