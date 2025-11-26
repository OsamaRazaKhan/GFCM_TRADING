import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/nav_controller.dart';
import 'package:gfcm_trading/utils/helpers/dede_time_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class PositionsHistoryScreen extends StatefulWidget {
  const PositionsHistoryScreen({super.key});
  @override
  State<PositionsHistoryScreen> createState() => _PositionsHistoryScreenState();
}

class _PositionsHistoryScreenState extends State<PositionsHistoryScreen>
    with RouteAware {
  ColorConstants colorConstants = ColorConstants();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NavController>().clearPositionsDate();
      Get.find<NavController>().getPositionsHistoryRecords();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Get.find<NavController>().getYourTradsHistory(loadMore: true);
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
      builder: (navController) {
        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Profit:",
                            size: 16.sp,
                            fw: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                          CustomText(
                            navController.totalProfit.toStringAsFixed(2),

                            size: 14.sp,
                            fw: FontWeight.w400,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Credit:",
                            size: 16.sp,
                            fw: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                          CustomText(
                            navController.yourCredit.toStringAsFixed(2),

                            size: 14.sp,
                            fw: FontWeight.w400,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Deposit:",
                            size: 16.sp,
                            fw: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                          CustomText(
                            navController.totalDeposits.toStringAsFixed(2),
                            size: 14.sp,
                            fw: FontWeight.w400,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Withdrawal:",
                            size: 16.sp,
                            fw: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                          CustomText(
                            navController.totalConfirmedWithdraws
                                .toStringAsFixed(2),
                            size: 14.sp,
                            fw: FontWeight.w400,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Commission:",
                            size: 16.sp,
                            fw: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                          CustomText(
                            navController.totalCommission.toString(),
                            size: 14.sp,
                            fw: FontWeight.w400,

                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Balance:",
                            size: 16.sp,
                            fw: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                          CustomText(
                            navController.selectedMode == "Real"
                                ? navController.yourBalance.toStringAsFixed(2)
                                : navController.demoBalance.toStringAsFixed(2),
                            size: 14.sp,
                            fw: FontWeight.w400,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorConstants.blackColor
                                    : colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: colorConstants.iconGrayColor),

              Flexible(
                child: Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            navController.closeTradeList.length +
                            (navController.hasPositionsMoreData
                                ? 1
                                : 0), // +1 for loader
                        itemBuilder: (context, index) {
                          if (index < navController.closeTradeList.length) {
                            final trade = navController.closeTradeList[index];
                            if (navController.closeTradeList.isEmpty &&
                                !navController.isLoadingMore) {
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 0.h,
                              ),
                              decoration: BoxDecoration(
                                color: colorConstants.bottomDarkGrayCol,
                                borderRadius: BorderRadius.circular(5.r),
                                border: Border(
                                  left: BorderSide(
                                    color:
                                        trade.stopLoss != null &&
                                                trade.stopLoss != 0.0 &&
                                                trade.takeProfit != null &&
                                                trade.takeProfit != 0.0
                                            ? Colors.transparent
                                            : trade.stopLoss != null &&
                                                trade.stopLoss != 0.0
                                            ? colorConstants.redColor
                                            : trade.takeProfit != null &&
                                                trade.takeProfit != 0.0
                                            ? colorConstants.blueColor
                                            : Colors
                                                .transparent, // border color
                                    width: 4, // border thickness
                                  ),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Row(
                                  children: [
                                    CustomText(
                                      "${trade.symbol},",
                                      size: 16.sp,
                                      fw: FontWeight.w600,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? colorConstants.blackColor
                                              : colorConstants.blackColor,
                                    ),
                                    SizedBox(width: 5.w),
                                    CustomText(
                                      '${trade.side == "BUY" ? 'Buy' : 'Sell'} ${trade.lots.toStringAsFixed(2)}',
                                      size: 12.sp,
                                      fw: FontWeight.w700,
                                      color:
                                          trade.side == "SELL"
                                              ? colorConstants.redColor
                                              : colorConstants.blueColor,
                                    ),
                                  ],
                                ),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CustomText(
                                          trade.startPrice.toString(),
                                          size: 14.sp,
                                          fw: FontWeight.w400,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? colorConstants.hintTextColor
                                                  : colorConstants
                                                      .hintTextColor,
                                        ),
                                        SizedBox(width: 5.w),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 12.sp,

                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? colorConstants.iconGrayColor
                                                  : colorConstants
                                                      .iconGrayColor,
                                        ),
                                        SizedBox(width: 5.w),
                                        CustomText(
                                          trade.currentPrice.toString(),
                                          size: 12.sp,
                                          fw: FontWeight.w400,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? colorConstants.hintTextColor
                                                  : colorConstants
                                                      .hintTextColor,
                                        ),
                                      ],
                                    ),
                                    CustomText(
                                      "Id: ${trade.tradeid.length > 6 ? trade.tradeid.substring(0, 6) : trade.tradeid}",
                                      size: 12.sp,
                                      fw: FontWeight.w400,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? colorConstants.hintTextColor
                                              : colorConstants.hintTextColor,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        if (trade.stopLoss != null &&
                                            trade.stopLoss != 0.0)
                                          CustomText(
                                            "SL: ${trade.stopLoss!.toStringAsFixed(2)}",
                                            size: 12.sp,
                                            color: colorConstants.redColor,
                                          ),
                                        SizedBox(
                                          width:
                                              trade.stopLoss == null ||
                                                      trade.stopLoss == 0.0
                                                  ? 0.w
                                                  : 8.w,
                                        ),
                                        if (trade.takeProfit != null &&
                                            trade.takeProfit != -0.0)
                                          CustomText(
                                            "TP: ${trade.takeProfit!.toStringAsFixed(2)}",
                                            size: 12.sp,
                                            color: colorConstants.blueColor,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CustomText(
                                      DedetimeHelper.dateTimeConverter(
                                        trade.dateTime,
                                      ),
                                      size: 12.sp,
                                      fw: FontWeight.w400,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? colorConstants.hintTextColor
                                              : colorConstants.hintTextColor,
                                    ),
                                    SizedBox(height: 5.h),
                                    CustomText(
                                      (trade.profitLose).toStringAsFixed(2),
                                      color:
                                          trade.profitLose < 0.0
                                              ? colorConstants.redColor
                                              : colorConstants.blueColor,
                                      size: 14.sp,
                                      fw: FontWeight.w800,
                                    ),
                                  ],
                                ),
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
}
