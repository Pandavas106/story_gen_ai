import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'story_generator_page.dart'; // Import your story generator page



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSignIn = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
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
                constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
                children: const [
                  Text('Sign In'),
                  Text('Sign Up'),
                ],
              ),
              const SizedBox(height: 20),
              showSignIn ? _buildSignInForm() : _buildSignUpForm(),
            ],
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
        _inputField('Password', controller: _passwordController, obscure: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _signIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Login'),
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
        _inputField('Password', controller: _passwordController, obscure: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _signUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Register'),
        ),
      ],
    );
  }

  Widget _inputField(String hint,
      {bool obscure = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFFE0B2), // light orange
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _signIn() async {
  try {
    await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    
    // Navigate to StoryGeneratorPage after successful login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StoryGeneratorPage()), // Navigate to story generator page
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful')),
    );
  } catch (e) {
    print('Login Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: ${e.toString()}')),
    );
  }
}


  void _signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up successful')),
      );
    } catch (e) {
      print('Sign Up Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    }
  }
}

