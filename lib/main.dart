import 'package:eduverse/pages/home_screen.dart';
import 'package:eduverse/pages/login_screen.dart';
import 'package:eduverse/pages/splash_screen.dart';
import 'package:eduverse/providers/auth_provider.dart';
import 'package:eduverse/services/navigation_service.dart';
import 'package:eduverse/services/snackbarServices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

const kWebRecaptchaSiteKey = '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(kWebRecaptchaSiteKey), 
      androidProvider: AndroidProvider.debug,
    );
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ],
        child: const StoryGenApp(),
      ),
    );
    print("Firebase success");
  } catch (e) {
    print("Firebase Init Error: $e");
  }
}

class StoryGenApp extends StatelessWidget {
  const StoryGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Gen AI',
      theme: ThemeData(primarySwatch: Colors.orange),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: Snackbarservices.instance.messengerKey,
      navigatorKey: NavigationService.instance.navigatorKey,
      initialRoute: "splashScreen",
      routes: {
        "login": (BuildContext context) => LoginScreen(),
        "splashScreen": (BuildContext context) => SplashScreen(),
        "home": (BuildContext context) => HomeScreen(),
      },
    );
  }
}
