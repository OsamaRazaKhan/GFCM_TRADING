import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/screens/fund_screens/funds_main_screen.dart';

class CurrentTotalAmountCard extends StatelessWidget {
  double totalCurrentAmount;
  CurrentTotalAmountCard({super.key, required this.totalCurrentAmount});

  ColorConstants colorConstants = ColorConstants();
  TradeChartController tradeChartController = Get.find<TradeChartController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: colorConstants.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(5, 5), // Right and bottom shadow
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CustomText("Net Balance", size: 16.sp, fw: FontWeight.w700),
              ],
            ),
            SizedBox(height: 13.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomText(
                      tradeChartController.equity.value == 0.0
                          ? tradeChartController.selectedMode.value == "Real"
                              ? (totalCurrentAmount +
                                      tradeChartController.balance.value)
                                  .toStringAsFixed(2)
                              : (tradeChartController.balance.value)
                                  .toStringAsFixed(2)
                          : tradeChartController.selectedMode.value == "Real"
                          ? (totalCurrentAmount +
                                  tradeChartController.equity.value)
                              .toStringAsFixed(2)
                          : (tradeChartController.equity.value).toStringAsFixed(
                            2,
                          ),
                      size: 12.sp,
                      fw: FontWeight.w700,
                    ),
                    SizedBox(width: 3.h),
                    CustomText(
                      "USD",
                      size: 13.sp,
                      fw: FontWeight.w500,
                      color: colorConstants.hintTextColor,
                    ),
                  ],
                ),

                CustomButton(
                  height: 26.h,
                  width: 80.w,
                  bordercircular: 5.r,
                  borderColor: Colors.transparent,
                  borderWidth: 2.sp,
                  text: "Add Funds",
                  textColor: colorConstants.whiteColor,
                  fontSize: 11.sp,
                  fw: FontWeight.w500,
                  boxColor: colorConstants.secondaryColor,
                  onTap: () {
                    Get.to(() => FundsMainScreen());
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  "Market Today",
                  size: 14.sp,
                  fw: FontWeight.w500,
                  color: colorConstants.hintTextColor,
                ),
                Transform.scale(
                  scale: 0.5,
                  child: Helper.svgIcon(
                    IconConstants.forwardSvg,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.hintTextColor,
                    height: 30,
                    width: 30,
                  ),
                ),
                CustomText(
                  "${tradeChartController.lastPrice.toStringAsFixed(2)} USD",
                  size: 12.sp,
                  fw: FontWeight.w700,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
