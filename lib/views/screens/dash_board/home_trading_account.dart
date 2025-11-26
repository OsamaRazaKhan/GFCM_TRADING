import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/home_controller.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:pie_chart/pie_chart.dart';

class HomeTradingAccount extends StatefulWidget {
  const HomeTradingAccount({super.key});

  @override
  State<HomeTradingAccount> createState() => _HomeTradingAccountState();
}

class _HomeTradingAccountState extends State<HomeTradingAccount> {
  TradeChartController tradeChartController = Get.put(TradeChartController());
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: colorConstants.bottomDarkGrayCol,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "Manage and Diversify Your Investments With Your Existing Trading Account",
            fw: FontWeight.w400,
            size: 12.sp,
          ),
          SizedBox(height: 15.h),

          Container(
            decoration: BoxDecoration(
              color: colorConstants.primaryColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                GetBuilder<HomeController>(
                  init: HomeController(),
                  builder: (homeController) {
                    return Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: colorConstants.lighBlueColor,
                      ),
                      child: Center(
                        child: PieChart(
                          dataMap: {
                            "Deposits": homeController.totalDeposits,
                            "Withdrawals":
                                homeController.totalConfirmedWithdraws,
                            "Balance":
                                double.tryParse(
                                  (homeController.userData?['balance'] ?? "0")
                                      .toString(),
                                ) ??
                                0.0,
                          },
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValuesInPercentage: true,
                          ),
                          chartRadius: MediaQuery.of(context).size.width / 3.2,
                          legendOptions: const LegendOptions(
                            legendPosition: LegendPosition.left,
                          ),
                          animationDuration: const Duration(milliseconds: 1200),
                          chartType: ChartType.disc,
                          colorList: colorConstants.colorList,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              CustomText(
                                "Balance",
                                size: 16.sp,
                                fw: FontWeight.w700,
                                color: colorConstants.blackColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomText(
                            "Equity",
                            size: 16.sp,
                            fw: FontWeight.w700,
                            color: colorConstants.blackColor,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomText(
                            "Free Margin",
                            size: 12.sp,
                            fw: FontWeight.w700,
                            color: colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Obx(() {
                  return Container(
                    padding: EdgeInsets.only(
                      left: 15.w,
                      right: 15.w,
                      bottom: 15.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          tradeChartController.balance.value.toStringAsFixed(2),
                          size: 12.sp,
                          fw: FontWeight.w500,
                          color: colorConstants.blackColor,
                        ),

                        CustomText(
                          tradeChartController.equity.value.toStringAsFixed(2),
                          size: 12.sp,
                          fw: FontWeight.w500,
                          color: colorConstants.blackColor,
                        ),

                        CustomText(
                          tradeChartController.freeMargin.value.toStringAsFixed(
                            2,
                          ),
                          size: 12.sp,
                          fw: FontWeight.w500,
                          color: colorConstants.blackColor,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
