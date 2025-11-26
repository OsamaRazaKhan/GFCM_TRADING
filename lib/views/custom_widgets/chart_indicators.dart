import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class ChartIndicators extends StatelessWidget {
  final double lastPrice;
  final String volume;
  final double spread;

  ChartIndicators({
    super.key,
    required this.lastPrice,
    required this.volume,
    required this.spread,
  });
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      color: colorConstants.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "XAUUSD",
            size: 12.sp,
            fw: FontWeight.w800,
            color: colorConstants.blueColor,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                "Last price: \$${lastPrice.toStringAsFixed(2)}",
                size: 10.sp,
                fw: FontWeight.w500,
              ),
              CustomText(
                "24h Vol: $volume",
                size: 10.sp,
                fw: FontWeight.w500,
                color: colorConstants.greenColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
