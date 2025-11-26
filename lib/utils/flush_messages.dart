import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gfcm_trading/constants/color_constants.dart';

class FlushMessages {
  static Future<void> commonToast(String msg, {Color? backGroundColor}) {
    ColorConstants colorConstants = ColorConstants();
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: backGroundColor ?? colorConstants.secondaryColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
