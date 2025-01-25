import  'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';


class ToastUtil {
  static void successToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green, // Success color
      textColor: Colors.white,
    );
  }

  static void failedToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red, // Error color
      textColor: Colors.white,
    );
  }
}

