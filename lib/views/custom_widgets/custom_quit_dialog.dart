import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CustomDialogs {
  static void showQuitDialog(
    BuildContext context, {
    double? height,
    double? width,
    double? radius,
    String? headText,
    String? messageText,
    String? quitText,
    String? cancelText,
    VoidCallback? onTap,
    bool? isChat = false,
    double? buttonHeight,
    bool? isDeleteLoading,
  }) {
    ColorConstants colorConstants = ColorConstants();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 0.r),
          ), // <- Proper corner radius
          child: Container(
            padding: EdgeInsets.all(5.r),
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: colorConstants.primaryColor,
              borderRadius: BorderRadius.circular(radius ?? 0.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 50,
                  color: colorConstants.redColor,
                ),
                SizedBox(height: 20.h),
                CustomText(
                  headText,
                  size: 16.sp,
                  fw: FontWeight.w700,
                  color: colorConstants.blackColor,
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.r),
                  child: CustomText(
                    messageText,
                    size: 10.sp,
                    fw: FontWeight.w600,
                    textAlign: TextAlign.center,
                    color: colorConstants.blackColor,
                  ),
                ),
                SizedBox(height: isChat == true ? 8.h : 30.h),
                isChat == true
                    ? SizedBox(
                      height: 36.h,
                      width: 36.w,
                      child: CircleAvatar(
                        backgroundColor:
                            colorConstants.redColor, // or any color
                        child: IconButton(
                          onPressed: onTap,
                          icon: Icon(
                            Icons.phone,
                            color: colorConstants.whiteColor,
                            size: 20.sp,
                          ),
                          padding: EdgeInsets.zero, // remove extra padding
                          constraints:
                              BoxConstraints(), // remove default IconButton constraints
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          bordercircular: 8.r,
                          boxColor: colorConstants.redColor,
                          text: quitText,
                          textColor: colorConstants.whiteColor,
                          fontSize: 12.sp,
                          fw: FontWeight.w600,
                          height: buttonHeight ?? 30.h,
                          width: 80.h,
                          horizontalPadding: 5.w,
                          borderColor: Colors.transparent,
                          onTap: onTap,
                        ),
                        CustomButton(
                          bordercircular: 8.r,
                          text: cancelText,
                          textColor: colorConstants.blackColor,
                          fontSize: 12.sp,
                          fw: FontWeight.w600,
                          height: buttonHeight ?? 30.h,
                          width: 80.h,
                          horizontalPadding: 5.w,
                          borderColor: colorConstants.blackColor,
                          onTap:
                              isDeleteLoading == true
                                  ? null
                                  : () {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Just close dialog
                                  },
                          loader: isDeleteLoading,
                        ),
                      ],
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
