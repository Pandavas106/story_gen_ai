import 'package:eduverse/services/app_navigation.dart';
import 'package:eduverse/utils/app_routes.dart';
import 'package:eduverse/services/db_service.dart';
import 'package:eduverse/services/snackbarServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  UserNotFound,
  Authenticated,
  UnAuthenticating,
  GoogleAuthenticating,
  ResetingPassword,
  PasswordResetEmailSent,
  Error,
}

class AuthProvider extends ChangeNotifier {
  User? user;
  late FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();
  AuthStatus status = AuthStatus.NotAuthenticated;
  BuildContext? _context;

  set buildContext(BuildContext context) {
    _context = context;
  }

  final Snackbarservices _snackbarservices = Snackbarservices.instance;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }
  void _checkCurrentUserIsAuthenticated() async {
    user = _auth.currentUser;
    status =
        user != null ? AuthStatus.Authenticated : AuthStatus.NotAuthenticated;
    notifyListeners();
  }

  void loginWithEmailAndPassword(String email, String password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = result.user;
      status = AuthStatus.Authenticated;
      _snackbarservices.showSnackbarSuccess("Successfully Logged In");


      AppNavigation.instance.navigateToReplacement(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      status = AuthStatus.Error;
      if (e.code == 'user-not-found') {
        _snackbarservices.showSnackbarError('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _snackbarservices.showSnackbarError('Wrong password provided.');
      } else if (e.code == 'invalid-email') {
        _snackbarservices.showSnackbarError('Email format is invalid.');
      } else if (e.code == 'invalid-credential') {
        Snackbarservices.instance.showSnackbarError(
          "Reset Your Password and try again.",
        );
      } else {
        _snackbarservices.showSnackbarError('Firebase error: ${e.message}');
        print('Firebase error: ${e.message}');
      }
    }
    notifyListeners();
  }

  void signInWithGoogle() async {
    status = AuthStatus.GoogleAuthenticating;
    notifyListeners();

    try {
      UserCredential _result = await _auth.signInWithProvider(
        GoogleAuthProvider(),
      );
      user = _result.user;

      DocumentSnapshot _doc =
          await FirebaseFirestore.instance
              .collection('EVUsers')
              .doc(user!.uid)
              .get();

      if (!_doc.exists) {
        // Create user in database if not exists
        DbService.instance.createUserInDB(
          user!.uid,
          user!.displayName ?? "",
          user!.email ?? "",
        );
      }

      status = AuthStatus.Authenticated;

      // Use centralized navigation service
      AppNavigation.instance.navigateToReplacement(AppRoutes.home);
    } catch (e) {
      print(e);
      status = AuthStatus.Error;
      _snackbarservices.showSnackbarError("Google sign-in failed");
    }
    notifyListeners();
  }

  // Reset password via email
  void passwordReset(String email) async {
    status = AuthStatus.ResetingPassword;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      status = AuthStatus.PasswordResetEmailSent;
      _snackbarservices.showSnackbarSuccess("Password reset email sent");
    } catch (e) {
      print(e);
      status = AuthStatus.Error;
      _snackbarservices.showSnackbarError("Failed to send reset email");
    }
    notifyListeners();
  }

  // Sign up with email and password
  void signUpWithEmailAndPassword(
    String email,
    String password,
    Future<void> Function(String uid) onSuccess,
  ) async {
    status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = result.user;

      await onSuccess(user!.uid);
      status = AuthStatus.Authenticated;
      _snackbarservices.showSnackbarSuccess("Account Created Successfully");

      AppNavigation.instance.navigateToReplacement(AppRoutes.home);
    } catch (e) {
      status = AuthStatus.Error;
      _snackbarservices.showSnackbarError("Authentication Error");
      print(e);
    }
    notifyListeners();
  }

  void logout(Future<void> Function() onSuccess) async {
    status = AuthStatus.UnAuthenticating;
    notifyListeners();

    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();

      AppNavigation.instance.navigateToReplacement(AppRoutes.login);
    } catch (e) {
      status = AuthStatus.Error;
      _snackbarservices.showSnackbarError("Error in Logout");
      print("Logout error: $e");
    }
    notifyListeners();
  }
}
