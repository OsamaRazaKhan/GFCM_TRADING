import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CustomEmptyScreenMessage extends StatelessWidget {
  final String? headText;
  final String? subtext;
  final Icon icon;
  VoidCallback? onTap;
  CustomEmptyScreenMessage({
    super.key,
    this.headText,
    this.subtext,
    required this.icon,
    this.onTap,
  });
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(height: 10.h),
          CustomText(
            headText,
            fw: FontWeight.w700,
            size: 18.sp,
            color: colorConstants.hintTextColor,
          ),
          SizedBox(height: 5),
          CustomText(
            subtext,
            fw: FontWeight.w400,
            size: 14.sp,
            color: colorConstants.hintTextColor,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: onTap,
            child: CustomText(
              "Refresh",
              size: 14.sp,
              fw: FontWeight.w500,
              color: colorConstants.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
