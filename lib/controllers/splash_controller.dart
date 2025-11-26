import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/login_screen.dart';
import 'package:gfcm_trading/views/screens/bottom_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController slideController;
  late AnimationController rotationController;

  late Animation<double> slideAnimation;
  late Animation<double> rotationAnimation;

  final RxDouble logoBottom = (-200.0).obs;

  @override
  void onInit() {
    super.onInit();

    slideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    rotationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: rotationController, curve: Curves.easeOut),
    );
  }

  void startAnimations(double screenHeight) {
    // Slide animation
    slideAnimation = Tween<double>(begin: -200.0, end: 500.h).animate(
      CurvedAnimation(parent: slideController, curve: Curves.easeInOut),
    )..addListener(() {
      logoBottom.value = slideAnimation.value;
    });

    // Start both animations
    slideController.forward();
    rotationController.forward();

    // When both animations complete
    Future.wait([
          slideController.forward().orCancel,
          rotationController.forward().orCancel,
        ])
        .then((_) async {
          SharedPreferences sp = await SharedPreferences.getInstance();
          String? userId = sp.getString("userId");

          Get.offAll(
            () =>
                (userId == null || userId.isEmpty)
                    ? LoginScreen()
                    : bottomNavScreen(),
          );
        })
        .catchError((e) {
          // Handle animation cancellation if needed
        });
  }

  @override
  void onClose() {
    slideController.dispose();
    rotationController.dispose();
    super.onClose();
  }
}



 
 

