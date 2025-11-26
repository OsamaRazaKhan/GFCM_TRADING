import 'package:flutter/material.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final FontWeight? fw;
  final Color? color;
  final double? size;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final FontStyle? fontStyle;
  final String? fontFamily;
  final int? maxLines;
  final TextStyle? textStyle;
  final TextDecoration? textDecoration;
  final double? height;

  bool? softWrap = false;
  CustomText(
    this.text, {
    super.key,
    this.fw,
    this.color,
    this.size,
    this.textAlign,
    this.textOverflow,
    this.fontStyle,
    this.fontFamily,
    this.maxLines,
    this.textStyle,
    this.textDecoration,
    this.height,
    this.softWrap,
  });
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: textAlign,
      softWrap: softWrap,
      style: textStyle ??
          GoogleFonts.outfit(
            fontSize: size,
            fontWeight: fw,
            color: color ?? colorConstants.blackColor,
            decoration:
                textDecoration ?? TextDecoration.none, // Apply underline
            decorationColor: colorConstants.blackColor, // Set underline color
            decorationThickness: 1.0, // Optional: Adjust thickness
            height: height,
          ),
    );
  }
}
