import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/kyc_controllers.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorConstants.blackColor),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: CustomText(
          "Identity Verification",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),
      body: GetBuilder<KycControllers>(
        init: KycControllers(),
        builder: (kycControllers) {
          if (!kycControllers.cameraController.value.isInitialized) {
            return Center(child: CircularProgressIndicator());
          }

          return Container(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      kycControllers.captureAndScanFace();
                    },
                    child: ClipOval(
                      child: SizedBox(
                        height: 300,
                        width: 300,
                        child: CameraPreview(kycControllers.cameraController),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                CustomText(
                  textAlign: TextAlign.center,
                  "Tap the circle to capture and scan your face",
                  color: colorConstants.blackColor,
                  fw: FontWeight.w500,
                  size: 16.sp,
                ),
                SizedBox(height: 20.h),
                if (kycControllers.scannedFaceFile != null)
                  Image.file(
                    kycControllers.scannedFaceFile!,
                    height: 150.h,
                    width: 150.w,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
