import 'package:eduverse/providers/auth_provider.dart';
import 'package:eduverse/services/app_navigation.dart';
import 'package:eduverse/utils/app_routes.dart';
import 'package:eduverse/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for a short time to show the splash screen
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for 2 seconds to display splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Get auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Set context for the auth provider
    authProvider.buildContext = context;
    
    // Check if user is authenticated
    final user = authProvider.user;
    
    // Navigate to appropriate screen based on auth status
    if (user != null) {
      AppNavigation.instance.navigateToReplacement(AppRoutes.home);
    } else {
      AppNavigation.instance.navigateToReplacement(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo 
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kprimarycolor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_stories,
                size: 70,
                color: kprimarycolor,
              ),
            ),
            const SizedBox(height: 24),
            
            // App name
            Text(
              'EduVerse',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: kprimarycolor,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Learn with interactive stories',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kprimarycolor),
            ),
          ],
        ),
      ),
    );
  }
}