import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:story/constant.dart';
import 'story_generator_page.dart';

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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
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
                        Container(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black.withOpacity(0.6),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(FontAwesomeIcons.google,color: kprimarycolor,),
                              ],
                            ),
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
          toggleVisibility:
              () => setState(() {
                _obsecureLogin = !_obsecureLogin;
              }),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
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
          toggleVisibility:
              () => setState(() {
                _obsecureSignUp = !_obsecureSignUp;
              }),
        ),
        const SizedBox(height: 20),
        Container(
          height: 40,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Register',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
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
        border: UnderlineInputBorder(
          borderSide: BorderSide.none, // Optional fallback
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

  void _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StoryGeneratorPage()),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));
    } catch (e) {
      print('Login Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  void _signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign up successful')));
    } catch (e) {
      print('Sign Up Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    }
  }
}
