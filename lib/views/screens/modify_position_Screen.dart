import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/models/position_model.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_dropdown_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class ModifyPositionScreen extends StatefulWidget {
  final double sL;
  final double tP;
  final double profitLoss;
  final Position trade;

  const ModifyPositionScreen({
    super.key,
    required this.sL,
    required this.tP,
    required this.trade,
    required this.profitLoss,
  });

  @override
  State<ModifyPositionScreen> createState() => _ModifyPositionScreenState();
}

class _ModifyPositionScreenState extends State<ModifyPositionScreen> {
  TradeChartController controller = Get.find<TradeChartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorConstants.blackColor),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: colorConstants.primaryColor,
      ),
      body: Obx(() {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          controller.closePosition(widget.trade.tradeid);
                          Navigator.pop(context);
                        },
                        child: CustomText(
                          "Close Position",
                          color: colorConstants.blackColor,
                          fw: FontWeight.w500,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                color: colorConstants.blackColor,
              ),

              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        // --- Header (Symbol & Position Info) ---
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(
                                        "XAUUSD",
                                        fw: FontWeight.w800,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 5.w),
                                      CustomText(
                                        "#${widget.trade.tradeid.substring(0, 6)}",
                                        fw: FontWeight.w500,
                                        size: 18.sp,
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      CustomText(
                                        '${widget.trade.side == TradeSide.buy ? 'Buy' : 'Sell'} ${widget.trade.lots.toStringAsFixed(2)}',
                                        size: 12.sp,
                                        fw: FontWeight.w700,
                                        color:
                                            widget.trade.side == TradeSide.sell
                                                ? colorConstants.redColor
                                                : colorConstants.blueColor,
                                      ),
                                      SizedBox(width: 5.w),
                                      CustomText(
                                        "at ${widget.trade.entryPrice}",
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              CustomText(
                                widget.profitLoss.toStringAsFixed(2),
                                color:
                                    widget.profitLoss >= 0
                                        ? colorConstants.blueColor
                                        : colorConstants.redColor,
                                fw: FontWeight.w700,
                                size: 18.sp,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        // --- Current Prices ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomText(
                              controller.bidPrice.toStringAsFixed(2),

                              size: 22,
                              fw: FontWeight.bold,
                              color: colorConstants.blueColor,
                            ),
                            CustomText(
                              controller.askPrice.toStringAsFixed(2),

                              size: 22.sp,
                              fw: FontWeight.bold,
                              color: colorConstants.redColor,
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // --- SL & TP Controls ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // SL Section
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove,
                                          color: colorConstants.redColor,
                                        ),
                                        onPressed:
                                            () => controller.decreaseSL(
                                              widget.trade.entryPrice,
                                            ),
                                      ),

                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller:
                                              controller.stopLossController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          textAlign:
                                              TextAlign
                                                  .center, // center input + hint
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$'),
                                            ),
                                          ],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                            color: colorConstants.blackColor,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "SL", // show SL as hint
                                            hintStyle: TextStyle(
                                              // style for SL hint
                                              fontWeight: FontWeight.w700,
                                              color: colorConstants.redColor,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            alignLabelWithHint:
                                                true, // ensures hint aligns properly
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: colorConstants.redColor,
                                        ),
                                        onPressed:
                                            () => controller.increaseSL(
                                              widget.trade.entryPrice,
                                            ),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    padding: EdgeInsets.all(1.r),
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      color: colorConstants.redColor,
                                    ),
                                  ),
                                ],
                              ),
                              // TP Section
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove,
                                          color: colorConstants.blueColor,
                                        ),
                                        onPressed:
                                            () => controller.decreaseTP(
                                              widget.trade.entryPrice,
                                            ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller:
                                              controller.takeProfitController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          textAlign:
                                              TextAlign
                                                  .center, // center input + hint
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$'),
                                            ),
                                          ],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                            color: colorConstants.blackColor,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "TP", // show SL as hint
                                            hintStyle: TextStyle(
                                              // style for SL hint
                                              fontWeight: FontWeight.w700,
                                              color: colorConstants.blueColor,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            alignLabelWithHint:
                                                true, // ensures hint aligns properly
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: colorConstants.blueColor,
                                        ),
                                        onPressed:
                                            () => controller.increaseTP(
                                              widget.trade.entryPrice,
                                            ),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    padding: EdgeInsets.all(1.r),
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      color: colorConstants.blueColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 130.h),
                        TextButton(
                          onPressed: () {
                            final double sl;
                            final double tp;
                            if (controller.stopLossController.text.isEmpty) {
                              sl = 0.0;
                            } else {
                              sl = double.parse(
                                double.parse(
                                  controller.stopLossController.text,
                                ).toStringAsFixed(2),
                              );
                            }
                            if (controller.takeProfitController.text.isEmpty) {
                              tp = 0.0;
                            } else {
                              tp = double.parse(
                                double.parse(
                                  controller.takeProfitController.text,
                                ).toStringAsFixed(2),
                              );
                            }
                            controller.setSLTP(
                              widget.trade.tradeid,
                              sl: sl,
                              tp: tp,
                            );
                          },
                          child: CustomText(
                            "Modify Position",
                            color: colorConstants.blackColor,
                            fw: FontWeight.w800,
                            size: 25.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
