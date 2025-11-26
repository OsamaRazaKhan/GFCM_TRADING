import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';

import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/kyc_controllers.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class ViewIdentityScreen extends StatefulWidget {
  const ViewIdentityScreen({super.key});

  @override
  State<ViewIdentityScreen> createState() => _ViewIdentityScreenState();
}

class _ViewIdentityScreenState extends State<ViewIdentityScreen> {
  ColorConstants colorConstants = ColorConstants();
  KycControllers kycControllers = Get.put(KycControllers());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      kycControllers.getUserData();
    });
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
          "View Identity",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),
      body: GetBuilder<KycControllers>(
        init: KycControllers(),
        builder: (kycControllers) {
          return Container(
            padding: EdgeInsets.all(10.r),
            child: kycControllers.isGetUserloading
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
                : kycControllers.userData == null
                    ? Align(
                        alignment: Alignment.center,
                        child: CustomEmptyScreenMessage(
                          icon: Icon(
                            Icons.cloud_off, // General error icon
                            size: 80.sp,
                            color: colorConstants.hintTextColor,
                          ),
                          headText: "Oops! Something Went Wrong",
                          subtext:
                              "Please try again later or refresh the page.",
                          onTap: () {
                            kycControllers.getUserData();
                          },
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              kycControllers.userData?["doctype"] == "ID Card"
                                  ? "Front Side Of Id:"
                                  : kycControllers.userData?["doctype"] ==
                                          "Passport"
                                      ? "Passport:"
                                      : "Licence",
                              color: colorConstants.blackColor,
                              fw: FontWeight.w600,
                              size: 16.sp,
                            ),
                            SizedBox(height: 5.h),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomImage(
                                      height: 20.h,
                                      width: 20.w,
                                      image: kycControllers.userData?[
                                                  "profileverification"] ==
                                              "Pending"
                                          ? AssetConstants.unverifiedBadge
                                          : AssetConstants.verifiedBadge,
                                    ),
                                  ],
                                ),
                                CustomImage(
                                  isNetwork: true,
                                  height: 400.h,
                                  width: Get.width,
                                  image: kycControllers
                                                  .userData?["cnicfront"] !=
                                              null ||
                                          kycControllers
                                                  .userData?["passport"] !=
                                              null
                                      ? "https://backend.gfcmgroup.com/${kycControllers.userData?[kycControllers.userData?["doctype"] == "Passport" || kycControllers.userData?["doctype"] == "License" ? "passport" : "cnicfront"]}"
                                      : null,
                                  iconSize: 100.sp,
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Visibility(
                              visible: kycControllers.userData?["doctype"] ==
                                  "ID Card",
                              child: CustomText(
                                "Back Side Of Id:",
                                color: colorConstants.blackColor,
                                fw: FontWeight.w600,
                                size: 16.sp,
                              ),
                            ),
                            Visibility(
                              visible: kycControllers.userData?["doctype"] ==
                                  "ID Card",
                              child: SizedBox(height: 5.h),
                            ),
                            Visibility(
                              visible: kycControllers.userData?["doctype"] ==
                                  "ID Card",
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomImage(
                                        height: 20.h,
                                        width: 20.w,
                                        image: kycControllers.userData?[
                                                    "profileverification"] ==
                                                "Pending"
                                            ? AssetConstants.unverifiedBadge
                                            : AssetConstants.verifiedBadge,
                                      ),
                                    ],
                                  ),
                                  CustomImage(
                                    isNetwork: true,
                                    height: 400.h,
                                    width: Get.width,
                                    image: kycControllers
                                                .userData?["cnicback"] !=
                                            null
                                        ? "https://backend.gfcmgroup.com/${kycControllers.userData?["cnicback"]}"
                                        : null,
                                    iconSize: 100.sp,
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: kycControllers.userData?["doctype"] ==
                                  "ID Card",
                              child: SizedBox(height: 20.h),
                            ),
                            CustomText(
                              "Selfie:",
                              color: colorConstants.blackColor,
                              fw: FontWeight.w600,
                              size: 16.sp,
                            ),
                            SizedBox(height: 5.h),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomImage(
                                      height: 20.h,
                                      width: 20.w,
                                      image: kycControllers.userData?[
                                                  "profileverification"] ==
                                              "Pending"
                                          ? AssetConstants.unverifiedBadge
                                          : AssetConstants.verifiedBadge,
                                    ),
                                  ],
                                ),
                                CustomImage(
                                  isNetwork: true,
                                  height: 400.h,
                                  width: Get.width,
                                  image: kycControllers.userData?["selfie"] !=
                                          null
                                      ? "https://backend.gfcmgroup.com/${kycControllers.userData?["selfie"]}"
                                      : null,
                                  iconSize: 100.sp,
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            CustomText(
                              "Utility Bill:",
                              color: colorConstants.blackColor,
                              fw: FontWeight.w600,
                              size: 16.sp,
                            ),
                            SizedBox(height: 5.h),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomImage(
                                      height: 20.h,
                                      width: 20.w,
                                      image: kycControllers.userData?[
                                                  "profileverification"] ==
                                              "Pending"
                                          ? AssetConstants.unverifiedBadge
                                          : AssetConstants.verifiedBadge,
                                    ),
                                  ],
                                ),
                                CustomImage(
                                  isNetwork: true,
                                  height: 400.h,
                                  width: Get.width,
                                  image: kycControllers.userData?["bill"] !=
                                          null
                                      ? "https://backend.gfcmgroup.com/${kycControllers.userData?["bill"]}"
                                      : null,
                                  iconSize: 100.sp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }
}
