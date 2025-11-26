import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/kyc_controllers.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image_selector.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class BackSideIdScreen extends StatefulWidget {
  const BackSideIdScreen({super.key});

  @override
  State<BackSideIdScreen> createState() => _BackSideIdScreenState();
}

class _BackSideIdScreenState extends State<BackSideIdScreen> {
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
        return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                CustomImageSelector(
                  onTap: () async {
                    await kycControllers.selectOrCaptureImage(
                      false,
                      false,
                    ); // Call the method
                  },
                  color: colorConstants.bottomDarkGrayCol,
                  height: 500.h,
                  width: Get.width,
                  controller: kycControllers,
                  image: kycControllers.backIdImage,
                ),

                SizedBox(height: 20.h),
                kycControllers.backIdImage != null
                    ? SizedBox()
                    : Container(
                      width: 64.w,
                      decoration: BoxDecoration(
                        color: colorConstants.bottomDarkGrayCol,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(
                          width: 2.w,
                          color: colorConstants.hintTextColor,
                        ),
                      ),
                    ),
                Visibility(
                  visible: kycControllers.backIdImage == null,
                  child: SizedBox(height: 20.h),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Column(
                    children: [
                      CustomText(
                        kycControllers.backIdImage != null
                            ? "ID Card"
                            : "Back Side Of ID",
                        color: colorConstants.blackColor,
                        fw: FontWeight.w600,
                        size: 18.sp,
                      ),
                      CustomText(
                        kycControllers.backIdImage != null
                            ? "Make sure that all the information on the document is visible and readable"
                            : "Take a photo of the back side of your identity document",
                        color: colorConstants.hintTextColor,
                        fw: FontWeight.w400,
                        size: 12.sp,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15.h),
                Align(
                  alignment: Alignment.center,
                  child: CustomButton(
                    icon:
                        kycControllers.backIdImage != null
                            ? null
                            : Icon(
                              Icons.upload,
                              color: colorConstants.hintTextColor,
                            ),
                    height: 44.h,
                    width: 259.w,
                    bordercircular: 10.r,
                    borderColor:
                        kycControllers.backIdImage != null
                            ? colorConstants.secondaryColor
                            : colorConstants.hintTextColor,
                    borderWidth: 2.sp,
                    text:
                        kycControllers.backIdImage != null
                            ? "Retake Photo"
                            : "Upload From Gallery",
                    textColor: colorConstants.hintTextColor,
                    fontSize: 14.sp,
                    fw: FontWeight.w500,

                    onTap: () {
                      kycControllers.selectOrCaptureImage(true, false);
                    },
                  ),
                ),

                SizedBox(height: 10.h),
                kycControllers.backIdImage != null
                    ? Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                        height: 44.h,
                        width: 259.w,
                        bordercircular: 10.r,
                        borderColor: Colors.transparent,
                        borderWidth: 2.sp,
                        text: "Ok",
                        textColor: colorConstants.primaryColor,
                        fontSize: 14.sp,
                        fw: FontWeight.w500,
                        boxColor: colorConstants.secondaryColor,
                        onTap: () {
                          Get.close(2);
                        },
                      ),
                    )
                    : SizedBox(),
                SizedBox(height: 10.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
