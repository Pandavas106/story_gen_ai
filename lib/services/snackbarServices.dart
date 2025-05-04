import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Snackbarservices {
  BuildContext? _buildContext;

  static Snackbarservices instance = Snackbarservices();
  final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  set buildContext(BuildContext context) {
    _buildContext = context;
  }

  void showSnackbarSuccess(String _message) {
    ScaffoldMessenger.of(_buildContext!).showSnackBar(
      SnackBar(
        content: Text(_message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void showSnackbarError(String _message) {
    ScaffoldMessenger.of(_buildContext!).showSnackBar(
      SnackBar(
        content: Text(_message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }
}
