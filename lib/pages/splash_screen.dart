import 'package:flutter/material.dart';
import 'login_screen.dart'; // instead of story_generator_page.dart


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _circleSize;
  late Animation<double> _textOpacity;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  bool hasTapped = false;

  @override
  void initState() {
    super.initState();

    // Main circle expand controller
    _expandController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _circleSize = Tween<double>(begin: 200.0, end: 2000.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutCubic),
    );

    _expandController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => LoginScreen(), // ← here
  ),
);

      }
    });

    // Glow animation controller
    _glowController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 8.0, end: 25.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _onTap() {
    if (hasTapped) return;
    hasTapped = true;

    _glowController.stop(); // Stop glow
    _expandController.forward(); // Start expand
  }

  @override
  void dispose() {
    _expandController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF3E0), // Light orange background
      body: GestureDetector(
        onTap: _onTap,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_expandController, _glowController]),
            builder: (context, child) {
              double size = _circleSize.value;
              bool isCircle = size < MediaQuery.of(context).size.width;
              double glow = hasTapped ? 0 : _glowAnimation.value;

              return Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  boxShadow: [
                    if (!hasTapped)
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: glow,
                        spreadRadius: glow / 2,
                      ),
                  ],
                ),
                child: Opacity(
                  opacity: _textOpacity.value,
                  child: Text(
                    'Story Gen AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
