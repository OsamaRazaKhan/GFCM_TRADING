import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CustomDashboardCardWidget extends StatelessWidget {
  Widget? svgIconWidget;
  double? amountTextSize;
  FontWeight? amountTextFw;
  Color? amountTextColor;
  String? amountText;
  String? text;
  double? textSize;
  FontWeight? textFw;
  Color? textColor;

  CustomDashboardCardWidget({
    super.key,
    this.svgIconWidget,
    this.amountText,
    this.amountTextSize,
    this.amountTextFw,
    this.amountTextColor,
    this.text,
    this.textSize,
    this.textFw,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    ColorConstants colorConstants = ColorConstants();
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          color: colorConstants.primaryColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: Offset(5, 5), // Right and bottom shadow
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            svgIconWidget ?? SizedBox(),
            SizedBox(height: 3.h),
            Expanded(
              child: Row(
                children: [
                  CustomText(
                    amountText,
                    size: amountTextSize,
                    fw: amountTextFw,
                    color: amountTextColor,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: CustomText(
                      " USD",
                      size: 11.sp,
                      fw: FontWeight.w400,
                      color: colorConstants.hintTextColor,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            Expanded(
              child: CustomText(
                text,
                size: textSize,
                fw: textFw,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
