import 'package:firebase_core/firebase_core.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyACNJNC_f_N1RlpC6Fsuud2xjhUj17Sjd4",
      appId: "1:1002537153078:android:0090f39e8df2acaa101e97",
      projectId: "sa2e7-database",
      storageBucket: "sa2e7-database.appspot.com",
      messagingSenderId: "1002537153078",
    ),
  );
}
