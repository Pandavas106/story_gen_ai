import 'package:eduverse/services/db_service.dart';
import 'package:eduverse/services/navigation_service.dart';
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
  Error,
}

class AuthProvider extends ChangeNotifier {
  User? user;
  late FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();
  AuthStatus status = AuthStatus.NotAuthenticated;
  final NavigationService _navigationService = NavigationService.instance;
  final Snackbarservices _snackbarservices = Snackbarservices.instance;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (user != null) {
      _navigationService.navigateToReplacement("home");
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = _auth.currentUser;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
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
      _navigationService.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      _snackbarservices.showSnackbarError("Authentication Error");
      print(e);
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
        DbService.instance.createUserInDB(
          user!.uid,
          user!.displayName ?? "",
          user!.email ?? "",
        );
      }
      user = _result.user;
      status = AuthStatus.Authenticated;
      _navigationService.navigateToReplacement("home");
    } catch (e) {
      print(e);
      status = AuthStatus.Error;
    }
    notifyListeners();
  }

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
      _navigationService.navigateToReplacement("home");
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
      _navigationService.navigateToReplacement("login");
    } catch (e) {
      status = AuthStatus.Error;
      _snackbarservices.showSnackbarError("Error in Logout");
    }
    notifyListeners();
  }
}
