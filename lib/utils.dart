import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Utils {
  Utils._();

  static getDate(DateTime date) {
    var day = date.toString().split(" ");
    return day.elementAt(0);
  }

  static showMessage(String message, BuildContext context) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}