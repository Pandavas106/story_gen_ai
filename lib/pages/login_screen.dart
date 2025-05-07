import 'package:eduverse/components/continue_with_google.dart';
import 'package:eduverse/components/forgot_password.dart';
import 'package:eduverse/constant.dart';
import 'package:eduverse/providers/auth_provider.dart';
import 'package:eduverse/services/db_service.dart';
import 'package:eduverse/services/snackbarServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSignIn = true;
  bool _obsecureLogin = true;
  bool _obsecureSignUp = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final DbService _dbService = DbService.instance;

  @override
  Widget build(BuildContext context) {
    Snackbarservices.instance.buildContext = context;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showSignIn ? "Welcome back!" : "Create Account",
                    style: TextStyle(
                      color: kprimarycolor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    showSignIn
                        ? "Please Log in to continue"
                        : "Sign up to get started with us",
                    style: TextStyle(
                      color: kcontentcolor,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 340,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ToggleButtons(
                          isSelected: [showSignIn, !showSignIn],
                          onPressed: (index) {
                            setState(() {
                              showSignIn = index == 0;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          selectedColor: Colors.white,
                          fillColor: Colors.orange,
                          color: Colors.orange,
                          constraints: const BoxConstraints(
                            minWidth: 100,
                            minHeight: 40,
                          ),
                          children: const [Text('Sign In'), Text('Sign Up')],
                        ),
                        const SizedBox(height: 20),
                        showSignIn ? _buildSignInForm() : _buildSignUpForm(),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: kcontentcolor,
                                thickness: 1,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "OR",
                                style: TextStyle(color: kcontentcolor),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: kcontentcolor,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: Consumer<AuthProvider>(
                            builder: (context, auth, child) {
                              bool isAuthenticating =
                                  auth.status ==
                                  AuthStatus.GoogleAuthenticating;
                              return ContinueWithGoogle(
                                isAuthenticating: isAuthenticating,
                                auth: auth,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      children: [
        _inputField('Email', controller: _emailController),
        const SizedBox(height: 10),
        _inputField(
          'Password',
          controller: _passwordController,
          obscure: _obsecureLogin,
          toggleVisibility: () {
            setState(() {
              _obsecureLogin = !_obsecureLogin;
            });
          },
        ),
        ForgotPassword(),
        const SizedBox(height: 20),
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            bool isAuthenticating = auth.status == AuthStatus.Authenticating;
            return SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  auth.loginWithEmailAndPassword(email, password);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAuthenticating ? Colors.white : Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: isAuthenticating ? 0 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    isAuthenticating
                        ? Center(
                          child: CircularProgressIndicator(
                            color: kprimarycolor,
                          ),
                        )
                        : Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        _inputField('Name', controller: _nameController),
        const SizedBox(height: 10),
        _inputField('Email', controller: _emailController),
        const SizedBox(height: 10),
        _inputField(
          'Password',
          controller: _passwordController,
          obscure: _obsecureSignUp,
          toggleVisibility: () {
            setState(() {
              _obsecureSignUp = !_obsecureSignUp;
            });
          },
        ),
        const SizedBox(height: 20),
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            bool isAuthenticating = auth.status == AuthStatus.Authenticating;
            return SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  auth.signUpWithEmailAndPassword(email, password, (uid) async {
                    await _dbService.createUserInDB(uid, name, email);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAuthenticating ? Colors.white : Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: isAuthenticating ? 0 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    isAuthenticating
                        ? Center(
                          child: CircularProgressIndicator(
                            color: kprimarycolor,
                          ),
                        )
                        : Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _inputField(
    String hint, {
    bool obscure = false,
    required TextEditingController controller,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kprimarycolor, width: 2),
        ),
        suffixIcon:
            toggleVisibility != null
                ? IconButton(
                  onPressed: toggleVisibility,
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    color: kcontentcolor,
                    size: 20,
                  ),
                )
                : null,
      ),
    );
  }
}
