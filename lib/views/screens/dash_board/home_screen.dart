import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/home_controller.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/current_total_amount_card.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_dashboard_card_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/demo_balance_dialog.dart';
import 'package:gfcm_trading/views/custom_widgets/reuseable_drawer_widget.dart';
import 'package:gfcm_trading/views/screens/dash_board/home_trading_account.dart';
import 'package:gfcm_trading/views/screens/notification_screen.dart';
import 'package:gfcm_trading/views/screens/referals_screen.dart'
    show ReferalsScreen;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController homeController = Get.put(HomeController());
  ColorConstants colorConstants = ColorConstants();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    homeController.getHomeScreenData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ReuseableDrawerWidget(),
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText("Home", size: 20.sp, fw: FontWeight.w500),
                SizedBox(width: 5.w),
              ],
            ),
          ],
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Transform.scale(
                  scale: 0.6,
                  child: Helper.svgIcon(
                    IconConstants.drawarSvg,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.blackColor,
                    height: 30,
                    width: 30,
                  ),
                ),
              ),
        ),

        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: CustomText(
                  "Help",
                  size: 18.sp,
                  fw: FontWeight.w400,
                  color: colorConstants.blueColor,
                ),
              ),
            ],
          ),

          GetBuilder<HomeController>(
            builder: (homeController) {
              return Stack(
                clipBehavior: Clip.none, // allows the badge to go outside
                children: [
                  IconButton(
                    onPressed: () {
                      Get.to(() => NotificationScreen());
                    },
                    icon: Transform.scale(
                      scale: 0.8,
                      child: Helper.svgIcon(
                        IconConstants.notificationSvg,
                        isSelected: false,
                        isOriginalColor: true,
                        originalColor: colorConstants.blueColor,
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),

                  //  Red circular badge with shadow
                  Visibility(
                    visible: homeController.notificationStatus,
                    child: Positioned(
                      right: 6, // adjust for perfect placement
                      top: 6,
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: colorConstants.redColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorConstants.redColor.withOpacity(
                                0.6,
                              ), // red shadow
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(width: 10.w),
        ],
      ),
      body: GetBuilder<HomeController>(
        init: HomeController(),
        builder: (homeController) {
          return homeController.isDemoBalanceLoader
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorConstants.secondaryColor,
                    ),
                  ),
                ),
              )
              : RefreshIndicator(
                color: colorConstants.secondaryColor,
                onRefresh: () async {
                  homeController.getHomeScreenData();
                  Get.find<TradeChartController>().getYourBalance();
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 15.w,
                        ),
                        padding: EdgeInsets.only(
                          left: 10.w,
                          right: 10.w,
                          top: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorConstants.bottomDarkGrayCol,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    CustomButton(
                                      width: 150.w,
                                      horizontalPadding: 5.w,
                                      height: 30.h,
                                      borderIsOnly: true,
                                      borderLeftTop: 4.r,
                                      borderLeftBottom: 4.r,
                                      borderColor:
                                          homeController.selectedMode == "Real"
                                              ? colorConstants.secondaryColor
                                              : colorConstants.blueColor,

                                      text: "Real",
                                      fontSize: 14.sp,
                                      fw: FontWeight.w500,
                                      icon: Icon(
                                        Icons.check_circle,
                                        size: 20.sp,
                                        color: colorConstants.secondaryColor,
                                      ),
                                      sizedBoxWidth: 8.w,
                                      onTap: () {
                                        homeController.selectMode("Real");
                                      },
                                      borderWidth:
                                          homeController.selectedMode == "Real"
                                              ? 2.w
                                              : 0.5.w,
                                    ),
                                    CustomButton(
                                      width: 150.w,
                                      horizontalPadding: 5.w,
                                      height: 30.h,
                                      borderIsOnly: true,
                                      borderRightTop: 4.r,
                                      borderRightBottom: 4.r,
                                      borderColor:
                                          homeController.selectedMode == "Demo"
                                              ? colorConstants.secondaryColor
                                              : colorConstants.blueColor,
                                      text: "Demo",
                                      fontSize: 14.sp,
                                      fw: FontWeight.w500,
                                      icon: Icon(
                                        Icons.smart_toy,
                                        color: Colors.blue,
                                        size: 20.sp,
                                      ),
                                      sizedBoxWidth: 8.w,
                                      onTap: () {
                                        DemoBelanceDilogWidget.demoDialog(
                                          context,
                                        );
                                      },
                                      borderWidth:
                                          homeController.selectedMode == "Demo"
                                              ? 2.w
                                              : 0.5.w,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 15.h),
                            CustomText(
                              "Your Finance’s at a Glance: Net Deposit,Wallet Total, and Reward Points Summary",
                              size: 12.sp,
                              fw: FontWeight.w400,
                              color: colorConstants.blackColor,
                            ),

                            SizedBox(height: 20.h),
                            CurrentTotalAmountCard(
                              totalCurrentAmount:
                                  homeController.yourTotalCurrent,
                            ),
                            SizedBox(height: 30.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 15.w),
                                    child: CustomDashboardCardWidget(
                                      svgIconWidget: Transform.scale(
                                        scale: 1.0,
                                        child: Helper.svgIcon(
                                          IconConstants.fundingSvg,
                                          isSelected: false,
                                          isOriginalColor: true,
                                          originalColor:
                                              colorConstants.secondaryColor,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                      amountText:
                                          homeController.selectedMode == "Real"
                                              ? (double.tryParse(
                                                    homeController
                                                            .userData?['wallet']
                                                            .toString() ??
                                                        "0",
                                                  )?.toStringAsFixed(2)) ??
                                                  "0.00"
                                              : "0.00",
                                      amountTextSize: 12.sp,
                                      amountTextFw: FontWeight.w700,
                                      amountTextColor:
                                          colorConstants.blackColor,
                                      text: "IN WALLET",
                                      textSize: 10.sp,
                                      textFw: FontWeight.w400,
                                      textColor: colorConstants.blackColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 15.w),
                                    child: CustomDashboardCardWidget(
                                      svgIconWidget: Transform.scale(
                                        scale: 0.8,
                                        child: Helper.svgIcon(
                                          IconConstants.bankSvg,
                                          isSelected: false,
                                          isOriginalColor: true,
                                          originalColor:
                                              colorConstants.secondaryColor,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                      amountText:
                                          homeController.selectedMode == "Real"
                                              ? (double.tryParse(
                                                    homeController
                                                            .userData?['balance']
                                                            .toString() ??
                                                        "0",
                                                  )?.toStringAsFixed(2)) ??
                                                  "0.00"
                                              : homeController.demoBalance
                                                  .toStringAsFixed(2),
                                      amountTextSize: 11.sp,
                                      amountTextFw: FontWeight.w700,
                                      amountTextColor:
                                          colorConstants.blackColor,
                                      text: "TRADE ACCOUNT",
                                      textSize: 10.sp,
                                      textFw: FontWeight.w400,
                                      textColor: colorConstants.blackColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 15.w),
                                    child: CustomDashboardCardWidget(
                                      svgIconWidget: Transform.scale(
                                        scale: 0.8,
                                        child: Helper.svgIcon(
                                          IconConstants.netSvg,
                                          isSelected: false,
                                          isOriginalColor: true,
                                          originalColor:
                                              colorConstants.secondaryColor,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                      amountText:
                                          homeController.selectedMode == "Real"
                                              ? homeController.totalDeposits
                                                  .toStringAsFixed(2)
                                              : "0.00",
                                      amountTextSize: 12.sp,
                                      amountTextFw: FontWeight.w700,
                                      amountTextColor:
                                          colorConstants.blackColor,
                                      text: "NET DEPOSIT",
                                      textSize: 10.sp,
                                      textFw: FontWeight.w400,
                                      textColor: colorConstants.blackColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 15.w),
                                    child: CustomDashboardCardWidget(
                                      svgIconWidget: Transform.scale(
                                        scale: 0.8,
                                        child: Helper.svgIcon(
                                          IconConstants.pointsSvg,
                                          isSelected: false,
                                          isOriginalColor: true,
                                          originalColor:
                                              colorConstants.secondaryColor,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                      amountText:
                                          homeController.selectedMode == "Real"
                                              ? (double.tryParse(
                                                    homeController
                                                            .userData?['social']
                                                            .toString() ??
                                                        "0",
                                                  )?.toStringAsFixed(2)) ??
                                                  "0.00"
                                              : "0.00",
                                      amountTextSize: 12.sp,
                                      amountTextFw: FontWeight.w700,
                                      amountTextColor:
                                          colorConstants.blackColor,
                                      text: "SOCIAL POINTS",
                                      textSize: 10.sp,
                                      textFw: FontWeight.w400,
                                      textColor: colorConstants.blackColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 15.w),
                                    child: CustomDashboardCardWidget(
                                      svgIconWidget: Transform.scale(
                                        scale: 0.8,
                                        child: Helper.svgIcon(
                                          IconConstants.totalWithDrawSvg,
                                          isSelected: false,
                                          isOriginalColor: true,
                                          originalColor:
                                              colorConstants.secondaryColor,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                      amountText:
                                          homeController.selectedMode == "Real"
                                              ? homeController
                                                  .totalConfirmedWithdraws
                                                  .toStringAsFixed(2)
                                              : "0.00",
                                      amountTextSize: 12.sp,
                                      amountTextFw: FontWeight.w700,
                                      amountTextColor:
                                          colorConstants.blackColor,
                                      text: "TOTAL WITHDRAW",
                                      textSize: 10.sp,
                                      textFw: FontWeight.w400,
                                      textColor: colorConstants.blackColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 15.w),
                                    child: CustomDashboardCardWidget(
                                      svgIconWidget: Transform.scale(
                                        scale: 0.8,
                                        child: Helper.svgIcon(
                                          IconConstants.partnerShipSvg,
                                          isSelected: false,
                                          isOriginalColor: true,
                                          originalColor:
                                              colorConstants.secondaryColor,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                      amountText:
                                          homeController.selectedMode == "Real"
                                              ? (double.tryParse(
                                                    homeController
                                                            .userData?['partner']
                                                            .toString() ??
                                                        "0",
                                                  )?.toStringAsFixed(2)) ??
                                                  "0.00"
                                              : "0.00",
                                      amountTextSize: 12.sp,
                                      amountTextFw: FontWeight.w700,
                                      amountTextColor:
                                          colorConstants.blackColor,
                                      text: "PARTNER ACCOUNT",
                                      textSize: 10.sp,
                                      textFw: FontWeight.w400,
                                      textColor: colorConstants.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                      HomeTradingAccount(),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.all(15.r),
                        margin: EdgeInsets.only(
                          left: 15.w,
                          right: 15.w,
                          bottom: 15.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorConstants.bottomDarkGrayCol,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "Invite Friends, Earn Rewards",
                              size: 20.sp,
                              fw: FontWeight.w500,
                              color: colorConstants.blackColor,
                            ),
                            CustomText(
                              "Invite your friends to join us and unlock a world of rewards. Sharing has never been more rewarding!",
                              size: 12.sp,
                              fw: FontWeight.w400,
                              color: colorConstants.blackColor,
                            ),
                            SizedBox(height: 40.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Get.to(
                                      () => ReferalsScreen(
                                        firstName:
                                            homeController
                                                .userData?["firstname"],
                                        lastName:
                                            homeController
                                                .userData?["lastname"],
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    size: 30.sp,
                                    color: colorConstants.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}
