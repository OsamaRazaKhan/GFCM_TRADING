import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class HistoryFilterTileWidget extends StatelessWidget {
  String? dateSelectedPeriod;
  final Icon icon;
  final String headText;
  final Color headTextColor;
  final double headTextSize;
  final FontWeight headTextFw;
  final String subText;
  final Color subTextColor;
  final double subTextSize;
  final FontWeight subTextFw;

  HistoryFilterTileWidget({
    super.key,
    required this.icon,
    required this.headText,
    required this.headTextColor,
    required this.headTextSize,
    required this.headTextFw,
    required this.subText,
    required this.subTextColor,
    required this.subTextSize,
    required this.subTextFw,
    this.dateSelectedPeriod,
  });
  ColorConstants colorConstants = ColorConstants();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            icon,
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  headText,
                  size: headTextSize,
                  color: headTextColor,
                  fw: headTextFw,
                ),
                CustomText(
                  subText,
                  size: subTextSize,
                  color: subTextColor,
                  fw: subTextFw,
                ),
              ],
            ),
          ],
        ),
        headText == dateSelectedPeriod
            ? Icon(Icons.check, size: 20.sp, color: colorConstants.blackColor)
            : SizedBox(),
      ],
    );
  }
}
