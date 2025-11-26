import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/nav_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_dropdown_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/history_filter_tile_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/reuseable_drawer_widget.dart';
import 'package:gfcm_trading/views/screens/history_screens.dart/commissions_history_screen.dart';
import 'package:gfcm_trading/views/screens/history_screens.dart/liquidated_history_screen.dart';
import 'package:gfcm_trading/views/screens/history_screens.dart/positions_history_screen.dart';

class HistoryMainScreen extends StatefulWidget {
  const HistoryMainScreen({super.key});

  @override
  State<HistoryMainScreen> createState() => _HistoryMainScreenState();
}

class _HistoryMainScreenState extends State<HistoryMainScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavController>(
      init: NavController(),
      builder: (navController) {
        return DefaultTabController(
          length: 3, // number of tabs

          child: Scaffold(
            drawer: ReuseableDrawerWidget(),

            //  (context) =>
            appBar: AppBar(
              backgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? colorConstants.primaryColor
                      : colorConstants.primaryColor,
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomText("History", size: 20.sp, fw: FontWeight.w500),
                      SizedBox(width: 5.w),
                    ],
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  color: colorConstants.primaryColor,
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          child: HistoryFilterTileWidget(
                            icon: Icon(
                              Icons.today,
                              size: 25.sp,
                              color: colorConstants.blackColor,
                            ),
                            headText: "Today",
                            headTextColor: colorConstants.blackColor,
                            headTextSize: 14.sp,
                            headTextFw: FontWeight.w600,
                            subText: navController.toDayDate ?? "",
                            subTextColor: colorConstants.hintTextColor,
                            subTextSize: 12.sp,
                            subTextFw: FontWeight.w500,
                            dateSelectedPeriod:
                                navController.selectedPeriod ?? "",
                          ),
                          onTap: () {
                            navController.selectDatePeriod("Today");
                          },
                        ),
                        PopupMenuDivider(), // Divider here
                        PopupMenuItem<String>(
                          child: HistoryFilterTileWidget(
                            icon: Icon(
                              Icons.calendar_view_week,
                              size: 25.sp,
                              color: colorConstants.blackColor,
                            ),
                            headText: "Last week",
                            headTextColor: colorConstants.blackColor,
                            headTextSize: 14.sp,
                            headTextFw: FontWeight.w600,
                            subText: navController.lastWeekDate ?? "",
                            subTextColor: colorConstants.hintTextColor,
                            subTextSize: 12.sp,
                            subTextFw: FontWeight.w500,
                            dateSelectedPeriod:
                                navController.selectedPeriod ?? "",
                          ),
                          onTap: () {
                            navController.selectDatePeriod("Last week");
                          },
                        ),
                        PopupMenuDivider(), // Divider here
                        PopupMenuItem<String>(
                          child: HistoryFilterTileWidget(
                            icon: Icon(
                              Icons.calendar_today,
                              size: 25.sp,
                              color: colorConstants.blackColor,
                            ),
                            headText: "Last month",
                            headTextColor: colorConstants.blackColor,
                            headTextSize: 14.sp,
                            headTextFw: FontWeight.w600,
                            subText: navController.lastMonthDate ?? "",
                            subTextColor: colorConstants.hintTextColor,
                            subTextSize: 12.sp,
                            subTextFw: FontWeight.w500,
                            dateSelectedPeriod:
                                navController.selectedPeriod ?? "",
                          ),
                          onTap: () {
                            navController.selectDatePeriod("Last month");
                          },
                        ),
                        PopupMenuDivider(), // Divider here
                        PopupMenuItem<String>(
                          child: HistoryFilterTileWidget(
                            icon: Icon(
                              Icons.calendar_month,
                              size: 25.sp,
                              color: colorConstants.blackColor,
                            ),
                            headText: "Last 3 months",
                            headTextColor: colorConstants.blackColor,
                            headTextSize: 14.sp,
                            headTextFw: FontWeight.w600,
                            subText: navController.lastThreeMonthsDate ?? "",
                            subTextColor: colorConstants.hintTextColor,
                            subTextSize: 12.sp,
                            subTextFw: FontWeight.w500,
                            dateSelectedPeriod:
                                navController.selectedPeriod ?? "",
                          ),
                          onTap: () {
                            navController.selectDatePeriod("Last 3 months");
                          },
                        ),
                        PopupMenuDivider(), // Divider here
                        PopupMenuItem<String>(
                          child: HistoryFilterTileWidget(
                            icon: Icon(
                              Icons.date_range,
                              size: 25.sp,
                              color: colorConstants.blackColor,
                            ),
                            headText: "Custom period",
                            headTextColor: colorConstants.blackColor,
                            headTextSize: 14.sp,
                            headTextFw: FontWeight.w600,
                            subText: navController.fromDate != null && navController.toDate != null
                                ? "${navController.fromDate} , ${navController.toDate}"
                                : "Select date range",
                            subTextColor: colorConstants.hintTextColor,
                            subTextSize: 12.sp,
                            subTextFw: FontWeight.w500,
                            dateSelectedPeriod:
                                navController.selectedPeriod ?? "",
                          ),
                          onTap: () {
                            navController.selectDatePeriod("Custom period");
                            navController.selectDate(context);
                          },
                        ),
                      ],
                  child:
                      navController.selectedIndex == 3
                          ? Transform.scale(
                            scale: 0.9,
                            child: Helper.svgIcon(
                              IconConstants.dateSelectorSvg,
                              isSelected: false,
                              isOriginalColor: true,
                              originalColor: colorConstants.blackColor,
                              height: 30,
                              width: 30,
                            ),
                          )
                          : SizedBox(),
                ),
                SizedBox(width: 12.w),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(50.h), // increase if needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    TabBar(
                      indicatorColor: colorConstants.blackColor,
                      tabs: [
                        Tab(
                          child: FittedBox(
                            child: CustomText(
                              "Positions",
                              color: colorConstants.blackColor,
                              size: 12.sp,
                              fw: FontWeight.w500,
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            child: CustomText(
                              "Liquidated Trades",
                              color: colorConstants.blackColor,
                              size: 12.sp,
                              fw: FontWeight.w500,
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            child: CustomText(
                              "Commissions",
                              color: colorConstants.blackColor,
                              size: 12.sp,
                              fw: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            body: TabBarView(
              children: [
                PositionsHistoryScreen(),
                LiquidatedHistoryScreen(),
                CommissionsHistoryScreen(),
              ],
            ),
          ),
        );
      },
    );
  }
}
