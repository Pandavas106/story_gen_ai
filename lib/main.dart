import 'package:flutter/material.dart';
import 'splash_screen.dart';  // Import the splash screen
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart'; // your login UI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(StoryGenApp());
}


class StoryGenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Gen AI',
      theme: ThemeData(primarySwatch: Colors.orange),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),  // Start with the splash screen
    );
  }
}
