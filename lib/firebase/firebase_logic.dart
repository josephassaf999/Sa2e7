import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fcm_notification_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Email/Password Login
  Future<User?> login({required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getReadableAuthError(e.code));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Email/Password Register
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (password != confirmPassword) {
        throw Exception('Passwords do not match.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long.');
      }
      if (email.isEmpty || name.isEmpty) {
        throw Exception('Email and name cannot be empty.');
      }

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
    } on FirebaseAuthException catch (e) {
      throw Exception(_getReadableAuthError(e.code));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
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
    } on FirebaseAuthException catch (e) {
      throw Exception(_getReadableAuthError(e.code));
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  /// Promote existing user to Business Owner
  Future<void> promoteToBusinessOwner({required String name}) async {
    final user = _auth.currentUser;
    if (user == null)
      throw Exception(
        'No user logged in. Please login to become a business owner.',
      );

    final uid = user.uid;

    // Update Users collection
    await _firestore.collection('Users').doc(uid).update({
      'isBusinessOwner': true,
      'businessName':
          name, // optional, can track business later in add business page
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Convert Firebase auth error codes to user-friendly messages
  String _getReadableAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'Authentication error: $code';
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;
}
