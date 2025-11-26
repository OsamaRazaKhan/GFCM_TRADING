import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/nav_controller.dart';
import 'package:gfcm_trading/utils/helpers/dede_time_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class LiquidatedHistoryScreen extends StatefulWidget {
  const LiquidatedHistoryScreen({super.key});

  @override
  State<LiquidatedHistoryScreen> createState() =>
      _LiquidatedHistoryScreenState();
}

class _LiquidatedHistoryScreenState extends State<LiquidatedHistoryScreen> {
  ColorConstants colorConstants = ColorConstants();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NavController>().clearLiquitedTradesDate();
      Get.find<NavController>().getYourLiquitedHistory();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Get.find<NavController>().getYourLiquitedHistory(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavController>(
      init: NavController(),
      builder: (navController) {
        return Container(
          padding: EdgeInsets.all(10.r),
          child: Column(
            children: [
              Flexible(
                child: Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            navController.liquitedTradesList.length +
                            (navController.hasLiquitedMoreData
                                ? 1
                                : 0), // +1 for loader
                        itemBuilder: (context, index) {
                          if (index < navController.liquitedTradesList.length) {
                            final trade =
                                navController.liquitedTradesList[index];
                            if (navController.liquitedTradesList.isEmpty &&
                                !navController.isLiquitedLoadingMore) {
                              return Center(
                                child: CustomText(
                                  "No trades found",
                                  color: colorConstants.hintTextColor,
                                ),
                              );
                            }

                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: colorConstants.bottomDarkGrayCol,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Top Row: Date + Last Price ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        DedetimeHelper.dateTimeConverter(
                                          trade.createdAt ??
                                              "2025-08-29T11:03:13.000Z",
                                        ),
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? colorConstants.blackColor
                                                : colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        "Last Price: ${double.parse(trade.lastPrice ?? "0.0").toStringAsFixed(2)}",
                                        size: 12.sp,
                                        fw: FontWeight.w500,
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),

                                  // --- Equity & Balance ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Equity: ${double.parse(trade.equity ?? "0.0").toStringAsFixed(2)}",
                                        size: 14.sp,
                                        fw: FontWeight.w600,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? colorConstants.blackColor
                                                : colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        "Balance: ${double.parse(trade.lastBalance ?? "0.0").toStringAsFixed(2)}",
                                        size: 14.sp,
                                        fw: FontWeight.w600,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? colorConstants.blackColor
                                                : colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),

                                  // --- Profit / Loss Highlight ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Profit/Loss",
                                        size: 12.sp,
                                        fw: FontWeight.w500,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? colorConstants.blackColor
                                                : colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        double.parse(
                                          trade.profitLoss == ""
                                              ? "0.0"
                                              : trade.profitLoss ?? "0.0",
                                        ).toStringAsFixed(2),
                                        size: 14.sp,
                                        fw: FontWeight.w700,
                                        color:
                                            (double.tryParse(
                                                          trade.profitLoss ??
                                                              "0",
                                                        ) ??
                                                        0) >=
                                                    0
                                                ? colorConstants.greenColor
                                                : colorConstants.redColor,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // --- Grid for Margin Details ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            "Margin",
                                            size: 11.sp,
                                            fw: FontWeight.w400,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? colorConstants.blackColor
                                                    : colorConstants.blackColor,
                                          ),
                                          CustomText(
                                            double.parse(
                                              trade.margin ?? "0.0",
                                            ).toStringAsFixed(2),
                                            size: 11.sp,
                                            fw: FontWeight.w600,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? colorConstants
                                                        .hintTextColor
                                                    : colorConstants
                                                        .hintTextColor,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            "Free Margin",
                                            size: 11.sp,
                                            fw: FontWeight.w400,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? colorConstants.blackColor
                                                    : colorConstants.blackColor,
                                          ),
                                          CustomText(
                                            double.parse(
                                              trade.freeMargin ?? "0.0",
                                            ).toStringAsFixed(2),

                                            size: 11.sp,
                                            fw: FontWeight.w600,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? colorConstants
                                                        .hintTextColor
                                                    : colorConstants
                                                        .hintTextColor,
                                          ),
                                        ],
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            "Margin Level",
                                            size: 11.sp,
                                            fw: FontWeight.w400,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? colorConstants.blackColor
                                                    : colorConstants.blackColor,
                                          ),
                                          CustomText(
                                            double.parse(
                                              trade.marginLevel ?? "0.0",
                                            ).toStringAsFixed(2),

                                            size: 11.sp,
                                            fw: FontWeight.w600,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? colorConstants
                                                        .hintTextColor
                                                    : colorConstants
                                                        .hintTextColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Loader at the end
                            return Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorConstants.secondaryColor,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Small reusable widget for bottom info
}
