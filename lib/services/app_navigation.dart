import 'package:flutter/material.dart';

/// A service class to centralize navigation operations in the app
class AppNavigation {
  static final AppNavigation _instance = AppNavigation._internal();
  
  /// Singleton instance
  static AppNavigation get instance => _instance;
  
  /// Private constructor
  AppNavigation._internal();
  
  /// Global navigation key to use for navigation without context
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    if (navigatorKey.currentState == null) {
      print("WARNING: Navigator key is null. Navigation failed.");
      return Future.value(null);
    }
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and remove all previous routes
  Future<dynamic> navigateToAndRemoveUntil(String routeName, {Object? arguments}) {
    if (navigatorKey.currentState == null) {
      print("WARNING: Navigator key is null. Navigation failed.");
      return Future.value(null);
    }
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Replace the current route with a new named route
  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    if (navigatorKey.currentState == null) {
      print("WARNING: Navigator key is null. Navigation failed.");
      return Future.value(null);
    }
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Pop the current route
  void goBack() {
    if (navigatorKey.currentState == null) {
      print("WARNING: Navigator key is null. Navigation failed.");
      return;
    }
    navigatorKey.currentState!.pop();
  }

  /// Go back to a specific route by popping until that route
  void goBackUntil(String routeName) {
    if (navigatorKey.currentState == null) {
      print("WARNING: Navigator key is null. Navigation failed.");
      return;
    }
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }
}