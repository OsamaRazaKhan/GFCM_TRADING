import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/settings_controller.dart';

class ColorConstants {
  bool get isDark =>
      Get.isRegistered<SettingsController>() &&
      Get.find<SettingsController>().isDarkTheme.value;

  Color get whiteColor => Colors.white;
  Color get primaryColor => isDark ? const Color(0xFF121212) : Colors.white;

  Color get secondaryColor => const Color(0xFFE0B45D);
  Color get offWhiteColor => isDark ? Colors.white : const Color(0xFF505050);

  Color get blackColor => isDark ? Colors.white : Colors.black;

  Color get boxgryColor =>
      isDark ? Colors.grey.shade800 : const Color(0xFFACACAC);

  Color get fieldTextColor =>
      isDark ? Colors.grey.shade300 : const Color(0xFFB2B2B2);

  Color get loginButtonColor =>
      isDark ? Colors.grey.shade700 : const Color(0xFFD9D9D9).withOpacity(0.29);

  Color get registerButtonColor =>
      isDark ? const Color(0xFFAC9245) : const Color(0x66E0B45D);

  Color get fingurePrintColor =>
      isDark
          ? const Color(0xFFAAAAAA).withOpacity(0.3)
          : const Color(0xFF696868).withOpacity(0.3);

  Color get fieldBorderColor => isDark ? Colors.grey : const Color(0xFFE0E0E0);

  Color get fieldColor =>
      isDark ? Colors.grey.shade900 : const Color(0xFFF4F4F4);

  Color get hintTextColor => isDark ? Colors.grey : const Color(0xFF878787);

  Color get blueColor => Colors.blue;

  Color get lightGrayColor =>
      isDark ? Colors.grey.shade800 : const Color(0xFFEAEAEA);

  Color get darkGrayColor =>
      isDark ? Colors.grey.shade300 : const Color(0xFF5E5E5E);

  Color get bottomDarkGrayCol =>
      isDark ? Colors.grey.shade900 : const Color(0xFFEEEEEE);

  Color get iconGrayColor =>
      isDark ? Colors.grey.shade500 : const Color(0xFF848484);

  Color get dimGrayColor =>
      isDark ? Colors.grey.shade600 : const Color(0xFF505050);

  Color get grayColor =>
      isDark ? Colors.grey.shade500 : const Color(0xFF212121);

  Color get greenColor => Colors.green;

  Color get redColor => Colors.red;

  Color get lightGreen =>
      isDark ? const Color(0xFF2E562E) : const Color(0xFFD6F3BA);

  Color get pinkColor =>
      isDark ? const Color(0xFF4D3A3A) : const Color(0xFFFFE6E6);

  Color get lightGray =>
      isDark ? Colors.grey.shade800 : const Color(0xFFDADADA);

  Color get lighBlueColor =>
      isDark ? const Color(0xFF2D3C3F) : const Color(0xFFEBFAFF);

  Color get tealColor => Colors.teal;

  Color get lightGoldColor =>
      isDark ? const Color(0xFF5B4A2E) : const Color(0xFFFFF6E0);

  List<Color> colorList = <Color>[Colors.blue, Colors.green, Colors.red];
}
