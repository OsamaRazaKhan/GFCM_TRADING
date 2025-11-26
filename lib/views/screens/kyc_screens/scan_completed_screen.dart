import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class ScanCompletedScreen extends StatefulWidget {
  const ScanCompletedScreen({super.key});

  @override
  State<ScanCompletedScreen> createState() => _ScanCompletedScreenState();
}

class _ScanCompletedScreenState extends State<ScanCompletedScreen> {
  ColorConstants colorConstants = ColorConstants();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 2), () async {
      Get.close(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        automaticallyImplyLeading: false,
        title: CustomText(
          "Identity Verification",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 100.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: colorConstants.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    height: 46.h,
                    width: 46.w,
                    decoration: BoxDecoration(
                      color: colorConstants.greenColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.center,
              child: CustomText(
                "Your Face Scan Is Complete",
                color: colorConstants.blackColor,
                fw: FontWeight.w500,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
