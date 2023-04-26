import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue,
        content: Text(
      msg,
      style: TextStyle(
        color: Colors.white,
      ),
    )));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}
