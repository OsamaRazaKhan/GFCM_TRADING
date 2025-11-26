import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.borderColor,
    this.boxColor,
    this.text,
    this.textColor,
    this.fontSize,
    this.textAlign,
    this.height,
    this.width,
    this.bordercircular,
    this.onTap,
    this.fw,
    this.borderWidth,
    this.image,
    this.icon,
    this.loader = false,
    this.horizontalPadding,
    this.verticalPadding,
    this.borderIsOnly = false,
    this.borderLeftTop,
    this.borderLeftBottom,
    this.borderRightTop,
    this.borderRightBottom,
    this.sizedBoxWidth,
  });
  final Color? borderColor;
  final Color? boxColor;
  final String? text;
  final Color? textColor;
  final double? fontSize;
  final TextAlign? textAlign;
  final double? height;
  final double? width;
  final double? bordercircular;
  final VoidCallback? onTap;
  final FontWeight? fw;
  final double? borderWidth;
  final String? image;
  final Icon? icon;
  final bool? loader;
  final double? horizontalPadding;
  final double? verticalPadding;
  final bool borderIsOnly;
  final double? borderLeftTop;
  final double? borderLeftBottom;
  final double? borderRightTop;
  final double? borderRightBottom;
  final double? sizedBoxWidth;

  @override
  Widget build(BuildContext context) {
    ColorConstants colorConstants = ColorConstants();
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? 0,
          vertical: verticalPadding ?? 0,
        ),
        height: height,
        width: width,
        decoration: BoxDecoration(
          border:
              borderColor != null
                  ? Border.all(color: borderColor!, width: borderWidth ?? 0.w)
                  : Border.all(),
          color: boxColor,
          borderRadius:
              borderIsOnly
                  ? BorderRadius.only(
                    topLeft: Radius.circular(borderLeftTop ?? 0.r),
                    bottomLeft: Radius.circular(borderLeftBottom ?? 0.r),
                    topRight: Radius.circular(borderRightTop ?? 0.r),
                    bottomRight: Radius.circular(borderRightBottom ?? 0.r),
                  )
                  : bordercircular == null
                  ? BorderRadius.all(Radius.circular(25))
                  : BorderRadius.all(Radius.circular(bordercircular!)),
        ),
        child: Center(
          child:
              image != null || icon != null && text != null
                  ? loader == true
                      ? CircularProgressIndicator(
                        color: colorConstants.primaryColor,
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon != null
                              ? icon!
                              : Container(
                                height: 20.h,
                                width: 20.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(image!),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                          SizedBox(width: sizedBoxWidth ?? 10.w),
                          CustomText(
                            text!,
                            fw: fw,
                            size: fontSize,
                            textAlign: textAlign,
                            color: textColor,
                          ),
                        ],
                      )
                  : icon ??
                      (loader == true
                          ? CircularProgressIndicator(
                            color: colorConstants.primaryColor,
                          )
                          : CustomText(
                            text ?? '',
                            fw: fw,
                            size: fontSize,
                            textAlign: textAlign,
                            color: textColor,
                          )),
        ),
      ),
    );
  }
}
