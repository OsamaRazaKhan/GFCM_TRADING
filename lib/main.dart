import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/settings_controller.dart';
import 'package:gfcm_trading/controllers/splash_controller.dart';

import 'package:gfcm_trading/views/screens/splash_screen.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(SettingsController());
  Get.put(SplashController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetBuilder<SettingsController>(
          builder: (settingsController) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'GFCM Trading',
              themeMode:
                  settingsController.isDarkTheme.value
                      ? ThemeMode.dark
                      : ThemeMode.light,
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
              ),
              home: SplashScreen(),
            );
          },
        );
      },
    );
  }
}
