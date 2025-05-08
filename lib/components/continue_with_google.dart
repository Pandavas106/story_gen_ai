import 'package:eduverse/constant.dart';
import 'package:eduverse/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContinueWithGoogle extends StatelessWidget {
  const ContinueWithGoogle({
    required this.isAuthenticating,
    required this.auth,
  });

  final bool isAuthenticating;
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black.withOpacity(0.6),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isAuthenticating ? 0 : 1,
      ),
      onPressed: () {
        auth.signInWithGoogle();
      },
      child:
          isAuthenticating
              ? Center(child: CircularProgressIndicator(color: kprimarycolor))
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continue with Google",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(width: 8),
                  Icon(FontAwesomeIcons.google, color: kprimarycolor),
                ],
              ),
    );
  }
}
