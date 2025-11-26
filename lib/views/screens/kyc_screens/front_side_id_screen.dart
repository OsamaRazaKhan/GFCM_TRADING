import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/kyc_controllers.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image_selector.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/screens/kyc_screens/back_side_id_screen.dart';

class FrontSideIdScreen extends StatefulWidget {
  const FrontSideIdScreen({super.key});

  @override
  State<FrontSideIdScreen> createState() => _FrontSideIdScreenState();
}

class _FrontSideIdScreenState extends State<FrontSideIdScreen> {
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
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CustomButton(
                          height: 30.h,
                          width: 100.w,
                          bordercircular: 5.r,
                          borderColor:
                              kycControllers.selectedDocType == "ID Card"
                                  ? Colors.transparent
                                  : colorConstants.hintTextColor,
                          borderWidth: 1.sp,
                          text: "ID Card",
                          textColor:
                              kycControllers.selectedDocType == "ID Card"
                                  ? colorConstants.primaryColor
                                  : colorConstants.hintTextColor,
                          fontSize: 14.sp,
                          fw: FontWeight.w500,
                          boxColor:
                              kycControllers.selectedDocType == "ID Card"
                                  ? colorConstants.secondaryColor
                                  : Colors.transparent,
                          onTap: () {
                            kycControllers.selectDoctype("ID Card");
                          },
                        ),
                        SizedBox(width: 10.w),
                        CustomButton(
                          height: 30.h,
                          width: 100.w,
                          bordercircular: 5.r,
                          borderColor:
                              kycControllers.selectedDocType == "Passport"
                                  ? Colors.transparent
                                  : colorConstants.hintTextColor,
                          borderWidth: 1.sp,
                          text: "Passport",
                          textColor:
                              kycControllers.selectedDocType == "Passport"
                                  ? colorConstants.primaryColor
                                  : colorConstants.hintTextColor,
                          fontSize: 14.sp,
                          fw: FontWeight.w500,
                          boxColor:
                              kycControllers.selectedDocType == "Passport"
                                  ? colorConstants.secondaryColor
                                  : Colors.transparent,
                          onTap: () {
                            kycControllers.selectDoctype("Passport");
                          },
                        ),
                        SizedBox(width: 10.w),
                        CustomButton(
                          height: 30.h,
                          width: 100.w,

                          bordercircular: 5.r,
                          borderColor:
                              kycControllers.selectedDocType == "Licence"
                                  ? Colors.transparent
                                  : colorConstants.hintTextColor,
                          borderWidth: 1.sp,
                          text: "Licence",
                          textColor:
                              kycControllers.selectedDocType == "Licence"
                                  ? colorConstants.primaryColor
                                  : colorConstants.hintTextColor,
                          fontSize: 14.sp,
                          fw: FontWeight.w500,
                          boxColor:
                              kycControllers.selectedDocType == "Licence"
                                  ? colorConstants.secondaryColor
                                  : Colors.transparent,
                          onTap: () {
                            kycControllers.selectDoctype("Licence");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomImageSelector(
                  onTap: () async {
                    await kycControllers.selectOrCaptureImage(
                      false,
                      true,
                    ); // Call the method
                  },
                  color: colorConstants.bottomDarkGrayCol,
                  height: 500.h,
                  width: Get.width,
                  controller: kycControllers,
                  image: kycControllers.frontIdImage,
                ),

                SizedBox(height: 20.h),
                kycControllers.frontIdImage != null
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
                  visible: kycControllers.frontIdImage == null,
                  child: SizedBox(height: 20.h),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Column(
                    children: [
                      CustomText(
                        kycControllers.selectedDocType == "Passport"
                            ? "Passport"
                            : kycControllers.selectedDocType == "Licence"
                            ? "Licence"
                            : kycControllers.frontIdImage != null
                            ? "ID Card"
                            : "Front Side Of ID",
                        color: colorConstants.blackColor,
                        fw: FontWeight.w600,
                        size: 18.sp,
                      ),
                      CustomText(
                        kycControllers.frontIdImage != null
                            ? "Make sure that all the information on the document is visible and readable"
                            : "Take a photo of the front side of your identity document",
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
                        kycControllers.frontIdImage != null
                            ? null
                            : Icon(
                              Icons.upload,
                              color: colorConstants.hintTextColor,
                            ),
                    height: 44.h,
                    width: 259.w,
                    bordercircular: 10.r,
                    borderColor:
                        kycControllers.frontIdImage != null
                            ? colorConstants.secondaryColor
                            : colorConstants.hintTextColor,
                    borderWidth: 2.sp,
                    text:
                        kycControllers.frontIdImage != null
                            ? "Retake Photo"
                            : "Upload From Gallery",
                    textColor: colorConstants.hintTextColor,
                    fontSize: 14.sp,
                    fw: FontWeight.w500,

                    onTap: () {
                      kycControllers.selectOrCaptureImage(true, true);
                    },
                  ),
                ),

                SizedBox(height: 10.h),
                kycControllers.frontIdImage != null
                    ? kycControllers.selectedDocType != "ID Card"
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
                              Get.close(1);
                            },
                          ),
                        )
                        : Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            height: 44.h,
                            width: 259.w,
                            bordercircular: 10.r,
                            borderColor: Colors.transparent,
                            borderWidth: 2.sp,
                            text: "Next",
                            textColor: colorConstants.primaryColor,
                            fontSize: 14.sp,
                            fw: FontWeight.w500,
                            boxColor: colorConstants.secondaryColor,
                            onTap: () {
                              Get.to(() => BackSideIdScreen());
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
