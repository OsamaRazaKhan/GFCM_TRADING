import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/kyc_controllers.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/screens/kyc_screens/face_verification_screen.dart';
import 'package:gfcm_trading/views/screens/kyc_screens/front_side_id_screen.dart';
import 'package:gfcm_trading/views/screens/kyc_screens/utility_bill_screen.dart';
import 'package:gfcm_trading/views/screens/kyc_screens/view_identity_screen.dart';

class KycMainScreen extends StatefulWidget {
  KycMainScreen({super.key});

  @override
  State<KycMainScreen> createState() => _KycMainScreenState();
}

class _KycMainScreenState extends State<KycMainScreen> {
  KycControllers kycControllers = Get.put(KycControllers());
  ColorConstants colorConstants = ColorConstants();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    kycControllers.getUserData();
  }

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
        builder: (kycControllers) {
          return Container(
            padding: EdgeInsets.all(15.r),
            child:
                kycControllers.isGetUserloading
                    ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorConstants.secondaryColor,
                          ),
                        ),
                      ),
                    )
                    : kycControllers.verificationStatus != null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
                            Visibility(
                              visible:
                                  kycControllers.verificationStatus ==
                                  "Pending",
                              child: CustomText(
                                "Verify Your Identity",
                                color: colorConstants.blackColor,
                                fw: FontWeight.w500,
                                size: 18.sp,
                              ),
                            ),
                            Visibility(
                              visible:
                                  kycControllers.verificationStatus ==
                                  "Pending",
                              child: CustomText(
                                "It Will Take Only 2 Minuts",
                                color: colorConstants.hintTextColor,
                                fw: FontWeight.w500,
                                size: 12.sp,
                              ),
                            ),
                            Visibility(
                              visible:
                                  kycControllers.verificationStatus ==
                                  "Pending",
                              child: SizedBox(height: 50.h),
                            ),

                            Visibility(
                              visible:
                                  kycControllers.verificationStatus ==
                                  "Pending",
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorConstants.bottomDarkGrayCol,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Get.to(() => FrontSideIdScreen());
                                  },
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Helper.svgIcon(
                                      IconConstants.identitySvg,
                                      isSelected: false,
                                      isOriginalColor: true,
                                      originalColor:
                                          colorConstants.secondaryColor,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  title: CustomText(
                                    "Identity Document",
                                    color: colorConstants.blackColor,
                                    fw: FontWeight.w500,
                                    size: 16.sp,
                                  ),
                                  subtitle: CustomText(
                                    "Take a photo of your iD",
                                    color: colorConstants.hintTextColor,
                                    fw: FontWeight.w500,
                                    size: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible:
                                  kycControllers.verificationStatus ==
                                  "Pending",
                              child: SizedBox(height: 10.h),
                            ),
                            Visibility(
                              visible:
                                  kycControllers.verificationStatus ==
                                  "Pending",
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorConstants.bottomDarkGrayCol,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Get.to(() => FaceVerificationScreen());
                                  },
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Helper.svgIcon(
                                      IconConstants.selfieSvg,
                                      isSelected: false,
                                      isOriginalColor: true,
                                      originalColor:
                                          colorConstants.secondaryColor,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  title: CustomText(
                                    "Selfie",
                                    color: colorConstants.blackColor,
                                    fw: FontWeight.w500,
                                    size: 16.sp,
                                  ),
                                  subtitle: CustomText(
                                    "Take a Selfie",
                                    color: colorConstants.hintTextColor,
                                    fw: FontWeight.w500,
                                    size: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible:
                                  kycControllers.verificationStatus ==
                                  "Pending",
                              child: SizedBox(height: 10.h),
                            ),

                            Visibility(
                              visible:
                                  kycControllers.verificationStatus ==
                                  "Pending",
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorConstants.bottomDarkGrayCol,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Get.to(() => UtilityBillScreen());
                                  },
                                  leading: Transform.scale(
                                    scale: 0.8,
                                    child: Helper.svgIcon(
                                      IconConstants.utilityBillsSvg,
                                      isSelected: false,
                                      isOriginalColor: true,
                                      originalColor:
                                          colorConstants.secondaryColor,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  title: CustomText(
                                    "Utility Bills",
                                    color: colorConstants.blackColor,
                                    fw: FontWeight.w500,
                                    size: 16.sp,
                                  ),
                                  subtitle: CustomText(
                                    "Take a photo of your utility bills",
                                    color: colorConstants.hintTextColor,
                                    fw: FontWeight.w500,
                                    size: 12.sp,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10.h),
                            Container(
                              decoration: BoxDecoration(
                                color: colorConstants.bottomDarkGrayCol,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Get.to(() => ViewIdentityScreen());
                                },
                                leading: Transform.scale(
                                  scale: 0.8,
                                  child: Icon(
                                    Icons.visibility_outlined,
                                    size: 25.sp,
                                    color: colorConstants.secondaryColor,
                                  ),
                                ),
                                title: CustomText(
                                  "View Identity",
                                  color: colorConstants.blackColor,
                                  fw: FontWeight.w500,
                                  size: 16.sp,
                                ),
                                subtitle: CustomText(
                                  "See your uploaded identity images",
                                  color: colorConstants.hintTextColor,
                                  fw: FontWeight.w500,
                                  size: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible:
                              kycControllers.verificationStatus == "Pending",
                          child: Align(
                            alignment: Alignment.center,
                            child: CustomButton(
                              height: 44.h,
                              width: 259.w,
                              bordercircular: 10.r,
                              borderColor: Colors.transparent,
                              borderWidth: 2.sp,
                              text: "Continue",
                              textColor: colorConstants.primaryColor,
                              fontSize: 14.sp,
                              fw: FontWeight.w500,
                              boxColor: colorConstants.secondaryColor,
                              onTap:
                                  kycControllers.isVerificationLoading
                                      ? null
                                      : () {
                                        kycControllers.verifyYourIdentity();
                                      },
                              loader: kycControllers.isVerificationLoading,
                            ),
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: CustomEmptyScreenMessage(
                        icon: Icon(
                          Icons.cloud_off, // General error icon
                          size: 80.sp,
                          color: colorConstants.hintTextColor,
                        ),
                        headText: "Oops! Something Went Wrong",
                        subtext: "Please try again later or refresh the page.",
                        onTap: () {
                          kycControllers.getUserData();
                        },
                      ),
                    ),
          );
        },
      ),
    );
  }
}
