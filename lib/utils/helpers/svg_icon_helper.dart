import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gfcm_trading/constants/color_constants.dart';

class Helper {
  static SvgPicture svgIcon(
    String src, {

    required bool isSelected,
    bool isOriginalColor = true,
    double? height,
    double? width,
    Color? originalColor,
  }) {
    ColorConstants colorConstants = ColorConstants();
    return SvgPicture.asset(
      src,
      height: height ?? 20.h,
      width: width ?? 20.w,
      colorFilter:
          isOriginalColor
              ? ColorFilter.mode(originalColor!, BlendMode.srcIn)
              : ColorFilter.mode(
                isSelected
                    ? colorConstants.secondaryColor
                    : colorConstants.iconGrayColor,
                BlendMode.srcIn,
              ),
    );
  }
}
