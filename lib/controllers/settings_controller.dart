import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingsController extends GetxController {
  RxBool isDarkTheme = false.obs;
  WebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkTheme.value = (prefs.getBool('isDarkTheme') ?? false);
    Get.changeThemeMode(isDarkTheme.value ? ThemeMode.dark : ThemeMode.light);
    update();

    //  Tell WebView chart to change theme
    if (webViewController != null) {
      webViewController!.runJavaScript(
        "changeTheme('${isDarkTheme.value ? 'dark' : 'light'}');",
      );
    }
  }

  void setTheme(bool value) async {
    isDarkTheme.value = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    update();

    //  Tell WebView chart to change theme
    if (webViewController != null) {
      webViewController!.runJavaScript(
        "changeTheme('${value ? 'dark' : 'light'}');",
      );
    }
  }
}
