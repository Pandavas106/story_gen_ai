import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigationService {
  late GlobalKey<NavigatorState> navigatorKey;
  static NavigationService instance = NavigationService();
  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String routename) {
    return navigatorKey.currentState!.pushReplacementNamed(routename);
  }

  Future<dynamic> navigateTo(String routename) {
    return navigatorKey.currentState!.pushNamed(routename);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute route) {
    return navigatorKey.currentState!.push(route);
  }

  bool goBack() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState?.pop();
      return true;
    }
    return false;
  }
}
