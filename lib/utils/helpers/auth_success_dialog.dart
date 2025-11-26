import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class AuthSuccessDialog {
  static void showSuccessDialog(
    BuildContext context, {
    bool isRegister = false,
    String? userId,
    String? password,
    String? server,
  }) {
    ColorConstants colorConstants = ColorConstants();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // First container (bottom background)
              Positioned(
                top: 10,
                child: Container(
                  //padding: EdgeInsets.only(top: 30.h),
                  width: 250.w,
                  height: 420.h,
                  decoration: BoxDecoration(
                    color: colorConstants.secondaryColor,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),

              // Second container (main box)
              Container(
                padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
                width: 300.w,
                height: 410.h,
                decoration: BoxDecoration(
                  color: colorConstants.primaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),
                    CustomText("Successful!", size: 25.sp, fw: FontWeight.w400),
                    SizedBox(height: 40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          "User Id",
                          size: 16.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                        ),
                        CustomText(
                          userId,
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.darkGrayColor,
                        ),
                      ],
                    ),
                    Divider(color: colorConstants.lightGrayColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          "Password",
                          size: 16.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                        ),
                        CustomText(
                          password,
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.darkGrayColor,
                        ),
                      ],
                    ),
                    Divider(color: colorConstants.lightGrayColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          "Server",
                          size: 16.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                        ),
                        CustomText(
                          server,
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.darkGrayColor,
                        ),
                      ],
                    ),
                    Divider(color: colorConstants.lightGrayColor),

                    SizedBox(height: 40.h),
                    GestureDetector(
                      onTap: () {
                        if (isRegister) {
                          Get.close(2);
                        }
                      },
                      child: CircleAvatar(
                        radius: 30.r,
                        backgroundColor: colorConstants.secondaryColor,
                        child: Icon(
                          Icons.clear,
                          size: 40.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Circular icon (on top center)
              Positioned(
                top: -50,
                child: CircleAvatar(
                  radius: 40.r,
                  backgroundColor: colorConstants.secondaryColor,
                  child: Icon(Icons.check, size: 50.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
