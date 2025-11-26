import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class ReuseableListTile extends StatefulWidget {
  final Widget? icon;
  String? titleText;
  double? titleTextSize;
  FontWeight? titleTextFw;
  Color? titleTextColor;
  bool isTraling;
  VoidCallback? onTap;
  ReuseableListTile({
    super.key,
    this.icon,
    this.titleText,
    this.titleTextColor,
    this.titleTextFw,
    this.titleTextSize,
    this.isTraling = false,
    this.onTap,
  });

  @override
  State<ReuseableListTile> createState() => _ReuseableListTileState();
}

class _ReuseableListTileState extends State<ReuseableListTile> {
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: 0.0,
        horizontal: 12.0,
      ), // Reduce vertical padding
      minVerticalPadding:
          0, // Further reduces internal height (if using newer Flutter SDK)
      dense: true, // Makes ListTile more compact
      visualDensity: VisualDensity(
        vertical: -1,
      ), // Optional: aggressively reduce space
      onTap: widget.onTap,
      leading: widget.icon ?? Icon(Icons.car_crash_sharp),

      title: Row(
        children: [
          CustomText(
            widget.titleText,
            color: widget.titleTextColor,
            fw: widget.titleTextFw,
            size: widget.titleTextSize,
          ),
        ],
      ),
      trailing:
          widget.isTraling
              ? CustomButton(
                height: 16.h,
                width: 16.w,
                boxColor: colorConstants.secondaryColor,
                bordercircular: 3.r,
                borderColor: Colors.transparent,
                text: "1",
                fontSize: 9.sp,
                fw: FontWeight.w400,
                textColor: colorConstants.primaryColor,
              )
              : SizedBox(),
    );
  }
}
