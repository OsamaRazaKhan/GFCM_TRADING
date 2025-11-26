import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';

class FingurprintBottomSheet {
  static void showBottomSheet(
    BuildContext context, {
    VoidCallback? onlongPressed,
  }) {
    ColorConstants colorConstants = ColorConstants();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(),
      builder: (context) {
        return GestureDetector(
          onLongPress: onlongPressed,
          child: SizedBox(
            height: 150.h,
            child: Center(
              child: Icon(
                Icons.fingerprint,
                size: 70.sp,
                color: colorConstants.secondaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
