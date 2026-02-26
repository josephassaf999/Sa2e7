import 'package:firebase_core/firebase_core.dart';
import 'firebase_config.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseConfig.apiKey,
      appId: FirebaseConfig.appId,
      projectId: FirebaseConfig.projectId,
      storageBucket: FirebaseConfig.storageBucket,
      messagingSenderId: FirebaseConfig.messagingSenderId,
    ),
  );
}
