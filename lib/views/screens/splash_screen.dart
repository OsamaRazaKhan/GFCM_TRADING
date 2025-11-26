import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/login_screen.dart';
import 'package:gfcm_trading/views/screens/bottom_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ColorConstants colorConstants = ColorConstants();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Get.put(TradeChartController(), permanent: true);

    Timer(Duration(seconds: 3), () async {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? userId = sp.getString("userId");

      Get.offAll(
        () =>
            (userId == null || userId.isEmpty)
                ? LoginScreen()
                : bottomNavScreen(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          CustomImage(
            height: screenHeight,
            width: screenWidth,
            image: AssetConstants.gfcmSplashImage,
          ),

          Positioned(
            left: 100,
            top: 170,
            right: 100,
            child: CustomImage(
              height: 174.h,
              width: 174.w,
              image: AssetConstants.gfcmLogo,
            ),
          ),

          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: CustomText(
                "Global Forex Capital Markets",
                fw: FontWeight.w500,
                size: 37.sp,
                color: colorConstants.whiteColor,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
