import 'package:eduverse/pages/home_screen.dart';
import 'package:eduverse/pages/login_screen.dart';
import 'package:eduverse/pages/splash_screen.dart';
import 'package:eduverse/providers/auth_provider.dart';
import 'package:eduverse/services/app_navigation.dart';
import 'package:eduverse/utils/app_routes.dart';
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

    // Initialize the application
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider.instance,
          ),
        ],
        child: const StoryGenApp(),
      ),
    );
    print("Firebase initialization successful");
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}

class StoryGenApp extends StatelessWidget {
  const StoryGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduVerse',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      navigatorKey: AppNavigation.instance.navigatorKey,

      scaffoldMessengerKey: Snackbarservices.instance.messengerKey,

      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
      },

      initialRoute: AppRoutes.splash,

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(child: Text('Route not found: ${settings.name}')),
              ),
        );
      },
    );
  }
}
