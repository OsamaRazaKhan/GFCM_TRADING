import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CustomTextFormField extends StatefulWidget {
  final bool readOnly;
  final bool isBottomBorder;
  final TextEditingController? controller;
  final Color? containerBorderColor;
  final String? labelText;
  final String? message;
  final String? hintText;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final double? width;
  final double? height;
  final bool isPassword;
  final Color? color;
  final FocusNode? focusNode;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool? isPass;
  final VoidCallback? obSecureTap;
  final bool? isObSecure;
  final String? Function(String?)? validateFunction;
  final Icon? prefixIcon;
  final Function(dynamic value)? onChanged;
  final bool? isSearch;
  final double? borderRadius;
  final double? containerBorderRadius;
  final Color? fillColor;
  final double? contentPaddingVertical;
  final double? contentPaddingHorizontal;
  final bool isLabel;
  final Color? labelTextColor;
  final FontWeight? labelTextFontWeight;
  final double? labelTextSize;
  final String? subLabelText;
  final Color? subLabelTextColor;
  final FontWeight? subLabelTextFontWeight;
  final double? subLabelTextSize;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? suffixTapAction;
  final Icon? icon;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final bool isRow;
  final int? maxLines;
  final Widget? suffixWidget;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final bool? isMultiline;
  final Color? inputTextColor;
  final Widget? child;
  const CustomTextFormField({
    super.key,
    this.readOnly = false,
    this.hintText,
    this.labelText,
    this.controller,
    this.message,
    this.borderColor = Colors.white,
    this.focusedBorderColor = Colors.white,
    this.errorBorderColor = Colors.red,
    this.width,
    this.height,
    this.isPassword = false,
    this.color,
    this.focusNode,
    this.hintStyle,
    this.isPass = false,
    this.obSecureTap,
    this.isObSecure = false,
    this.validateFunction,
    this.prefixIcon,
    this.onChanged,
    this.isSearch = false,
    this.borderRadius,
    this.containerBorderRadius,
    this.fillColor,
    this.contentPaddingVertical,
    this.contentPaddingHorizontal,
    this.isLabel = false,
    this.labelTextColor,
    this.labelTextFontWeight,
    this.labelTextSize,
    this.subLabelTextColor,
    this.subLabelTextFontWeight,
    this.subLabelTextSize,
    this.subLabelText,
    this.labelStyle,
    this.inputFormatters,
    this.suffixTapAction,
    this.icon,
    this.onTap,
    this.keyboardType,
    this.isRow = false,
    this.maxLines,
    this.suffixWidget,
    this.containerBorderColor,
    this.textInputAction,
    this.onFieldSubmitted,
    this.isMultiline,
    this.isBottomBorder = false,
    this.inputTextColor,
    this.child,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

ColorConstants colorConstants = ColorConstants();

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          widget.containerBorderRadius ?? 1.r,
        ),
        border: Border.all(
          color: widget.containerBorderColor ?? Colors.transparent,
        ),
      ),
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        style: TextStyle(
          color: widget.inputTextColor ?? colorConstants.blackColor,
        ),
        maxLines: widget.isMultiline == true ? null : 1,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        focusNode: widget.focusNode,
        obscureText:
            widget.isObSecure ?? false, // Toggle visibility based on state
        obscuringCharacter: "*",
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        controller: widget.controller,
        decoration: InputDecoration(
          label:
              widget.isLabel
                  ? widget.isRow
                      ? Row(
                        children: [
                          CustomText(
                            widget.labelText, // Label (Main title)
                            size: widget.labelTextSize,
                            fw: widget.labelTextFontWeight,
                            color: widget.labelTextColor,
                          ),
                          SizedBox(width: 3.w),
                          CustomText(
                            widget.subLabelText, // Subtitle
                            size: widget.labelTextSize,
                            color: widget.subLabelTextColor,
                            fw: widget.subLabelTextFontWeight,
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            widget.labelText, // Label (Main title)
                            size: widget.labelTextSize,
                            fw: widget.labelTextFontWeight,
                            color: widget.labelTextColor,
                          ),
                          CustomText(
                            widget.subLabelText, // Subtitle
                            size: widget.labelTextSize,
                            color: widget.subLabelTextColor,
                            fw: widget.subLabelTextFontWeight,
                          ),
                        ],
                      )
                  : null,
          labelText: widget.isLabel ? null : widget.labelText,
          labelStyle:
              widget.labelStyle ??
              TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                color: Color(0xFF9E9E9E),
              ),
          hintStyle:
              widget.isLabel
                  ? null
                  : widget.hintStyle ??
                      TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Color(0xFF9E9E9E),
                      ),
          hintText: widget.isLabel ? null : widget.hintText,
          contentPadding: EdgeInsets.symmetric(
            vertical: widget.contentPaddingVertical ?? 16.0,
            horizontal: widget.contentPaddingHorizontal ?? 12.0,
          ),
          border:
              widget.isBottomBorder
                  ? UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: 2.0,
                    ),
                  )
                  : widget.isSearch == true
                  ? UnderlineInputBorder(
                    borderSide: BorderSide(width: 2.0.w),
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? 16.r,
                    ),
                  )
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? 16.r,
                    ),
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: 2.0,
                    ),
                  ),
          focusedBorder:
              widget.isBottomBorder
                  ? UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: 2.0,
                    ),
                  )
                  : widget.isSearch == true
                  ? UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.focusedBorderColor),
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? 16.r,
                    ),
                  )
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? 16.r,
                    ),
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: 2.0.w,
                    ),
                  ),
          enabledBorder:
              widget.isBottomBorder
                  ? UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: 2.0,
                    ),
                  )
                  : widget.isSearch == true
                  ? UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? 16.r,
                    ),
                    borderSide: BorderSide(color: widget.focusedBorderColor),
                  )
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? 16.r,
                    ),
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: 2.0,
                    ),
                  ),
          errorBorder:
              widget.isBottomBorder
                  ? UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.errorBorderColor,
                      width: 2.0,
                    ),
                  )
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? 16.r,
                    ),
                    borderSide: BorderSide(color: widget.errorBorderColor),
                  ),
          focusedErrorBorder:
              widget.isBottomBorder
                  ? UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.errorBorderColor,
                      width: 2.0,
                    ),
                  )
                  : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius ?? 16.r,
                    ),
                    borderSide: BorderSide(
                      color: widget.errorBorderColor,
                      width: 2.0.w,
                    ),
                  ),
          prefixIcon:
              widget.child == null
                  ? null
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.child!,
                      SizedBox(width: 10.w),
                      Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorConstants.fieldTextColor,
                          ),
                          color: colorConstants.fieldTextColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],
                  ),
          suffixIcon:
              widget.suffixWidget ??
              (widget.suffixTapAction != null
                  ? InkWell(onTap: widget.suffixTapAction, child: widget.icon)
                  : widget.obSecureTap != null
                  ? InkWell(
                    onTap: widget.obSecureTap,
                    child:
                        widget.isObSecure!
                            ? Icon(
                              Icons.visibility_off_outlined,
                              color: colorConstants.fieldTextColor,
                            )
                            : Icon(
                              Icons.remove_red_eye,
                              color: colorConstants.fieldTextColor,
                            ),
                  )
                  : null),
          fillColor: widget.fillColor ?? Colors.white24,
          filled: true,
        ),
        readOnly: widget.readOnly,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        inputFormatters: widget.inputFormatters,
        validator: widget.validateFunction,
      ),
    );
  }
}
