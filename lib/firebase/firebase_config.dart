/// Firebase configuration constants
/// IMPORTANT: Replace these values with your actual Firebase credentials from Google Cloud Console
///
/// To get these values:
/// 1. Go to Firebase Console: https://console.firebase.google.com
/// 2. Select your project (Sa2e7)
/// 3. Go to Project Settings (gear icon)
/// 4. Under "Your apps", find your Android app
/// 5. Copy the values from the configuration
///
/// Setup Instructions:
/// 1. Copy firebase_config.dart.example to firebase_config.dart
/// 2. Fill in your actual Firebase credentials
/// 3. This file is in .gitignore - never commit real credentials!
///
/// For local development, you can also:
/// - Use the google-services.json file from Firebase Console (preferred)
/// - Set environment variables that this file can read
class FirebaseConfig {
  static const String apiKey = "AIzaSyACNJNC_f_N1RlpC6Fsuud2xjhUj17Sjd4";
  static const String appId = "1:1002537153078:android:0090f39e8df2acaa101e97";
  static const String projectId = "sa2e7-database";
  static const String storageBucket = "sa2e7-database.firebasestorage.app";
  static const String messagingSenderId = "1002537153078";
}
