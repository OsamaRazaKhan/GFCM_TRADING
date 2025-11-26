import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/models/position_model.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class TopTradePanel extends StatelessWidget {
  TopTradePanel({super.key});
  final ColorConstants colorConstants = ColorConstants();

  @override
  Widget build(BuildContext context) {
    final chartController =
        Get.find<TradeChartController>(); // use existing instance
    return GetBuilder<TradeChartController>(
      builder: (tradeChartController) {
        return Row(
          children: [
            // SELL
            Expanded(
              child: InkWell(
                onTap: () {
                  if (chartController.marketOpen.value) {
                    chartController.openTrade(TradeSide.sell);
                  } else {
                    FlushMessages.commonToast(
                      "The market is currently closed. Orders will be accepted once the market resumes normal trading hours",
                      backGroundColor: colorConstants.dimGrayColor,
                    );
                  }
                },
                child: Container(
                  height: 50.h,
                  color:
                      tradeChartController.isConnectedToInterNet.value
                          ? colorConstants.redColor
                          : colorConstants.redColor.withOpacity(
                            0.8,
                          ), // dim red,
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: FittedBox(
                    child: Column(
                      children: [
                        CustomText(
                          "Sell",
                          color: colorConstants.whiteColor,
                          size: 14.sp,
                          fw: FontWeight.w500,
                        ),
                        Text(
                          chartController.bidPrice.value.toStringAsFixed(2),
                          style: TextStyle(
                            color: colorConstants.whiteColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // LOT INPUT (unchanged except removed init)
            Expanded(
              child: Container(
                height: 50.h,
                color: colorConstants.lightGray,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          chartController.increaseValue();
                        },
                        child: Icon(
                          Icons.arrow_drop_up,
                          size: 20.sp,
                          color: colorConstants.blackColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: chartController.loteSizeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],

                          onChanged:
                              (val) => chartController.setValueFromInput(
                                val,
                              ), // raw, flexible
                          onSubmitted:
                              (val) => chartController.setValueFromInput(
                                val,
                                format: true,
                              ), // round & sync
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                            color: colorConstants.blackColor,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          chartController.decreaseValue();
                        },
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: 20.sp,
                          color: colorConstants.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BUY
            Expanded(
              child: InkWell(
                onTap: () {
                  if (chartController.marketOpen.value) {
                    chartController.openTrade(TradeSide.buy);
                  } else {
                    FlushMessages.commonToast(
                      "The market is currently closed. Orders will be accepted once the market resumes normal trading hours",
                      backGroundColor: colorConstants.dimGrayColor,
                    );
                  }
                },
                child: Container(
                  height: 50.h,
                  color:
                      tradeChartController.isConnectedToInterNet.value
                          ? colorConstants.blueColor
                          : colorConstants.blueColor.withOpacity(0.8),
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: FittedBox(
                    child: Column(
                      children: [
                        CustomText(
                          "Buy",
                          color: colorConstants.whiteColor,
                          size: 14.sp,
                          fw: FontWeight.w500,
                        ),
                        Text(
                          chartController.askPrice.value.toStringAsFixed(2),
                          style: TextStyle(
                            color: colorConstants.whiteColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
