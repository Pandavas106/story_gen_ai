import 'package:eduverse/services/navigation_service.dart';
import 'package:eduverse/services/snackbarServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  UserNotFound,
  Authenticated,
  UnAuthenticating,
  Error,
}

class AuthProvider extends ChangeNotifier {
  User? user;
  late FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();
  AuthStatus status = AuthStatus.NotAuthenticated;
  NavigationService _navigationService = NavigationService.instance;
  Snackbarservices _snackbarservices = Snackbarservices.instance;

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
    user = await _auth.currentUser;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  void loginWithEmailAndPassword(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      user = _result.user;
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

  void signUpWithEmailAndPassword(
    String _email,
    String _password,
    Future<void> onSuccess(String uid),
  ) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      user = _result.user;
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

  void logout(Future<void> onSuccess()) async {
    status = AuthStatus.UnAuthenticating;
    notifyListeners();
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
    } catch (e) {
      status = AuthStatus.Error;
      _snackbarservices.showSnackbarError("Error in Logout");
    }
    notifyListeners();
  }
}
