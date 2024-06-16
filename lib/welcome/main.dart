import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'onboarding_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyACNJNC_f_N1RlpC6Fsuud2xjhUj17Sjd4',
    appId: '1:1002537153078:android:0090f39e8df2acaa101e97',
    messagingSenderId: '1002537153078',
    projectId: 'sa2e7-database',
    storageBucket: 'sa2e7-database.appspot.com',
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnBoardingScreen(),
    );
  }
}
