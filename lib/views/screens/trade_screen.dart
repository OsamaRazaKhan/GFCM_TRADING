import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/models/close_trades_model.dart';
import 'package:gfcm_trading/models/position_model.dart';
import 'package:gfcm_trading/models/pending_order_model.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/utils/helpers/calculate_PL.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/reuseable_drawer_widget.dart';
import 'package:gfcm_trading/views/screens/modify_position_Screen.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> with RouteAware {
  ColorConstants colorConstants = ColorConstants();
  TradeChartController tradeChartController = Get.find<TradeChartController>();
  int itemCount = 0;
  String fmt(num v) => v.isNaN ? '--' : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ReuseableDrawerWidget(),
      //(context) =>
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        leading: Builder(
          builder: (context) => IconButton(
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
        title: Obx(() {
          final pl = tradeChartController.totalUnrealizedPL;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText("Trade", size: 20.sp, fw: FontWeight.w500),
                  SizedBox(width: 5.w),
                  Container(
                    height: 10.h,
                    width: 10.h,
                    decoration: BoxDecoration(
                      color: tradeChartController.selectedMode.value == "Real"
                          ? colorConstants.secondaryColor
                          : colorConstants.blueColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Visibility(visible: pl != 0.0, child: SizedBox(width: 3.w)),
              Visibility(
                visible: pl != 0.0,
                child: CustomText(
                  "${pl.toStringAsFixed(2)} USD",
                  color: pl >= 0
                      ? colorConstants.blueColor
                      : colorConstants.redColor,
                  fw: FontWeight.w600,
                  size: 12.sp,
                ),
              ),
            ],
          );
        }),
      ),
      body: Obx(() {
        return !tradeChartController.isConnectedToInterNet.value &&
                tradeChartController.positions.isEmpty
            ? Padding(
                padding: EdgeInsets.all(10.r),
                child: CustomEmptyScreenMessage(
                  icon: Icon(
                    Icons.cloud_off,
                    size: 80.sp,
                    color: colorConstants.hintTextColor,
                  ),
                  headText: "Temporary Data Issue",
                  subtext:
                      "We’re having trouble loading your live trades and price data. Our system will automatically reconnect once the network stabilizes",
                  onTap: () {
                    tradeChartController.checkInternet();
                  },
                ),
              )
            : tradeChartController.bidPrice.value == 0.0 ||
                    tradeChartController.askPrice.value == 0.0 ||
                    tradeChartController.isbalanceLoader.value
                ? Center(
                    child: // Loader at the end
                        Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorConstants.secondaryColor,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        child: Obx(() {
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      "Balance:",
                                      size: 16.sp,
                                      fw: FontWeight.w500,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? colorConstants.blackColor
                                          : colorConstants.blackColor,
                                    ),
                                    CustomText(
                                      fmt(tradeChartController.balance.value),
                                      size: 14.sp,
                                      fw: FontWeight.w400,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      "Equity:",
                                      size: 16.sp,
                                      fw: FontWeight.w500,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? colorConstants.blackColor
                                          : colorConstants.blackColor,
                                    ),
                                    CustomText(
                                      fmt(tradeChartController.equity.value),
                                      size: 14.sp,
                                      fw: FontWeight.w400,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? colorConstants.blackColor
                                          : colorConstants.blackColor,
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: tradeChartController.credit.value >
                                        0.0 &&
                                    tradeChartController.selectedMode.value ==
                                        "Real",
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Credit:",
                                        size: 16.sp,
                                        fw: FontWeight.w500,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? colorConstants.blackColor
                                            : colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        fmt(tradeChartController.credit.value),
                                        size: 14.sp,
                                        fw: FontWeight.w400,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? colorConstants.blackColor
                                            : colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: tradeChartController
                                        .positions.isNotEmpty &&
                                    tradeChartController.marginUsed.value > 0,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Margin:",
                                        size: 16.sp,
                                        fw: FontWeight.w500,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? colorConstants.blackColor
                                            : colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        fmt(tradeChartController
                                            .marginUsed.value),
                                        size: 14.sp,
                                        fw: FontWeight.w400,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? colorConstants.blackColor
                                            : colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      "Free Margin:",
                                      size: 16.sp,
                                      fw: FontWeight.w500,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? colorConstants.blackColor
                                          : colorConstants.blackColor,
                                    ),
                                    CustomText(
                                      fmt(tradeChartController
                                          .freeMargin.value),
                                      size: 14.sp,
                                      fw: FontWeight.w400,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? colorConstants.blackColor
                                          : colorConstants.blackColor,
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: tradeChartController
                                        .positions.isNotEmpty &&
                                    tradeChartController.marginUsed.value > 0,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Margin Level(%):",
                                        size: 16.sp,
                                        fw: FontWeight.w500,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? colorConstants.blackColor
                                            : colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        tradeChartController.marginUsed.value >
                                                0
                                            ? tradeChartController
                                                .marginLevelPct.value
                                                .toStringAsFixed(2)
                                            : '--',
                                        size: 14.sp,
                                        fw: FontWeight.w400,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? colorConstants.blackColor
                                            : colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      Divider(color: colorConstants.iconGrayColor),
                      Visibility(
                        visible: tradeChartController.positions.isNotEmpty ||
                            tradeChartController.pendingOrders.isNotEmpty,
                        child: ListTile(
                          onTap: () {
                            if (tradeChartController
                                .isConnectedToInterNet.value) {
                              if (tradeChartController.marketOpen.value) {
                                showModalBottomSheet(
                                  backgroundColor: colorConstants.primaryColor,
                                  context: context,
                                  shape: RoundedRectangleBorder(),
                                  builder: (context) {
                                    return SizedBox(
                                      height: 250.h,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(10.r),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CustomText(
                                                  "Bulk Operations",
                                                  size: 14.sp,
                                                  fw: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            color: colorConstants.hintTextColor,
                                          ),
                                          Obx(() {
                                            final c = tradeChartController;

                                            // Check for both active positions AND pending orders
                                            bool hasActivePositions =
                                                c.positions.isNotEmpty;

                                            bool hasProfitable =
                                                c.positions.any((p) {
                                              final exitPrice = (p.side ==
                                                      TradeSide.buy)
                                                  ? c.bidPrice
                                                      .value // Buyers close at Bid
                                                  : c.askPrice
                                                      .value; // Sellers close at Ask

                                              final pl = (p.side ==
                                                      TradeSide.buy)
                                                  ? (exitPrice - p.entryPrice) *
                                                      p.lots *
                                                      p.contractSize
                                                  : (p.entryPrice - exitPrice) *
                                                      p.lots *
                                                      p.contractSize;

                                              return pl > 0;
                                            });

                                            bool hasLosing =
                                                c.positions.any((p) {
                                              final exitPrice =
                                                  (p.side == TradeSide.buy)
                                                      ? c.bidPrice.value
                                                      : c.askPrice.value;

                                              final pl = (p.side ==
                                                      TradeSide.buy)
                                                  ? (exitPrice - p.entryPrice) *
                                                      p.lots *
                                                      p.contractSize
                                                  : (p.entryPrice - exitPrice) *
                                                      p.lots *
                                                      p.contractSize;

                                              return pl < 0;
                                            });

                                            return Expanded(
                                              child: Container(
                                                padding: EdgeInsets.all(10.r),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (hasActivePositions)
                                                      TextButton(
                                                        onPressed: () {
                                                          if (tradeChartController
                                                              .isConnectedToInterNet
                                                              .value) {
                                                            if (tradeChartController
                                                                .marketOpen
                                                                .value) {
                                                              if (!tradeChartController
                                                                  .isLiquidating) {
                                                                c.closeAllPositions();
                                                              }
                                                            } else {
                                                              FlushMessages
                                                                  .commonToast(
                                                                "The market is currently closed. You cannot close or modify trades until it reopens",
                                                                backGroundColor:
                                                                    colorConstants
                                                                        .dimGrayColor,
                                                              );
                                                            }
                                                          }
                                                        },
                                                        child: CustomText(
                                                          'Close All Positions',
                                                          size: 14,
                                                          fw: FontWeight.w400,
                                                        ),
                                                      ),
                                                    if (hasProfitable)
                                                      TextButton(
                                                        onPressed: () {
                                                          if (tradeChartController
                                                              .isConnectedToInterNet
                                                              .value) {
                                                            if (tradeChartController
                                                                .marketOpen
                                                                .value) {
                                                              if (!tradeChartController
                                                                  .isLiquidating) {
                                                                c.closeProfitablePositions();
                                                              }
                                                            } else {
                                                              FlushMessages
                                                                  .commonToast(
                                                                "The market is currently closed. You cannot close or modify trades until it reopens",
                                                                backGroundColor:
                                                                    colorConstants
                                                                        .dimGrayColor,
                                                              );
                                                            }
                                                          }
                                                        },
                                                        child: CustomText(
                                                          'Close Profit Positions',
                                                          size: 14,
                                                          fw: FontWeight.w400,
                                                        ),
                                                      ),
                                                    if (hasLosing)
                                                      TextButton(
                                                        onPressed: () {
                                                          if (tradeChartController
                                                              .isConnectedToInterNet
                                                              .value) {
                                                            if (tradeChartController
                                                                .marketOpen
                                                                .value) {
                                                              if (!tradeChartController
                                                                  .isLiquidating) {
                                                                c.closeLosingPositions();
                                                              }
                                                            } else {
                                                              FlushMessages
                                                                  .commonToast(
                                                                "The market is currently closed. You cannot close or modify trades until it reopens",
                                                                backGroundColor:
                                                                    colorConstants
                                                                        .dimGrayColor,
                                                              );
                                                            }
                                                          }
                                                        },
                                                        child: CustomText(
                                                          'Close Negative Positions',
                                                          size: 14,
                                                          fw: FontWeight.w400,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                FlushMessages.commonToast(
                                  "The market is currently closed. You cannot close or modify trades until it reopens",
                                  backGroundColor: colorConstants.dimGrayColor,
                                );
                              }
                            }
                          },
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0,
                            horizontal: 12.0,
                          ), // Reduce vertical padding
                          minVerticalPadding:
                              0, // Further reduces internal height (if using newer Flutter SDK)
                          dense: true, // Makes ListTile more compact
                          visualDensity: VisualDensity(vertical: -1),
                          leading: CustomText(
                            "Positions",
                            size: 16.sp,
                            fw: FontWeight.w500,
                            color: colorConstants.hintTextColor,
                          ),
                          trailing: Icon(
                            Icons.more_horiz,
                            size: 20.sp,
                            color: colorConstants.hintTextColor,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: tradeChartController.positions.isNotEmpty ||
                            tradeChartController.pendingOrders.isNotEmpty,
                        child: Divider(color: colorConstants.iconGrayColor),
                      ),
                      Expanded(
                        child: Obx(() {
                          final c = tradeChartController;
                          final allItems = c.allTradeItems;
                          bool shouldRefresh = false;
                          if (allItems.length < itemCount || allItems.isEmpty) {
                            shouldRefresh = true;
                          }
                          itemCount = allItems.length;
                          return shouldRefresh
                              ? FutureBuilder(
                                  future: c
                                      .refreshAllTradeData(), // ALWAYS refresh once
                                  builder: (context, snapshot) {
                                    // While refreshing (initial load)
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: colorConstants.secondaryColor,
                                        ),
                                      );
                                    }

                                    // After refresh completes, still empty → show message
                                    return RefreshIndicator(
                                      color: colorConstants.secondaryColor,
                                      onRefresh: () async {
                                        await c
                                            .refreshAllTradeData(); // manual refresh
                                      },
                                      child: SingleChildScrollView(
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          child: Center(
                                            child: CustomText(
                                              "No trades found",
                                              size: 14.sp,
                                              color:
                                                  colorConstants.hintTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : RefreshIndicator(
                                  color: colorConstants.secondaryColor,
                                  onRefresh: () async {
                                    await c.refreshAllTradeData();
                                  },
                                  child: ListView.builder(
                                    itemCount: allItems.length,
                                    // Optimize for smooth scrolling
                                    cacheExtent: 500,
                                    addAutomaticKeepAlives: false,
                                    addRepaintBoundaries: true,
                                    itemBuilder: (context, i) {
                                      final item = allItems[i];
                                      final isPendingOrder =
                                          item is PendingOrder;

                                      return Column(
                                        key: Key(isPendingOrder
                                            ? 'pending_${item.orderId}'
                                            : 'position_${item.tradeid}'),
                                        children: [
                                          if (i > 0)
                                            Divider(
                                              color:
                                                  colorConstants.iconGrayColor,
                                              height: 1,
                                            ),

                                          // Show active trades or pending orders
                                          if (isPendingOrder)
                                            _buildPendingOrderTile(item, c)
                                          else
                                            _buildActiveTradeTile(item, c),
                                        ],
                                      );
                                    },
                                  ),
                                );
                        }),
                      ),
                    ],
                  );
      }),
    );
  }

  // Helper method to build pending order tile
  Widget _buildPendingOrderTile(PendingOrder order, TradeChartController c) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: colorConstants.lightGoldColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.schedule,
          color: colorConstants.secondaryColor,
          size: 24.sp,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: CustomText(
              "${order.side == TradeSide.buy ? 'BUY' : 'SELL'} ${order.lots.toStringAsFixed(2)} @ ${order.entryPrice.toStringAsFixed(2)}",
              size: 14.sp,
              textOverflow: TextOverflow.ellipsis,
              fw: FontWeight.w600,
            ),
          ),
          // CustomText(
          //     "${order.side == TradeSide.buy ? 'BUY' : 'SELL'} ${order.lots.toStringAsFixed(2)} @ ${order.entryPrice.toStringAsFixed(2)}",
          //     size: 14.sp,
          //     fw: FontWeight.w600,
          //   ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colorConstants.secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: CustomText(
              "Waiting",
              size: 9.sp,
              color: colorConstants.secondaryColor,
              fw: FontWeight.w600,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Obx(() {
            final currentPrice = order.side == TradeSide.buy
                ? c.askPrice.value
                : c.bidPrice.value;
            return CustomText(
              "Current: ${currentPrice > 0 ? currentPrice.toStringAsFixed(2) : 'N/A'}",
              size: 12.sp,
              color: colorConstants.hintTextColor,
            );
          }),
          if (order.stopLoss > 0 || order.takeProfit > 0) ...[
            SizedBox(height: 4.h),
            CustomText(
              "SL: ${order.stopLoss > 0 ? order.stopLoss.toStringAsFixed(2) : 'N/A'} | TP: ${order.takeProfit > 0 ? order.takeProfit.toStringAsFixed(2) : 'N/A'}",
              size: 12.sp,
              color: colorConstants.hintTextColor,
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.close,
          color: colorConstants.redColor,
          size: 20.sp,
        ),
        onPressed: () async {
          await c.cancelPendingOrder(order);
        },
      ),
    );
  }

  // Helper method to build active trade tile (optimized for performance)
  Widget _buildActiveTradeTile(Position p, TradeChartController c) {
    final exitPrice =
        (p.side == TradeSide.buy) ? c.bidPrice.value : c.askPrice.value;
    final pl = CalculatePl.calculatePL(
        p, exitPrice, tradeChartController.kGoldContractSizePerLot);

    return ListTile(
      onLongPress: () {
        if (tradeChartController.isConnectedToInterNet.value) {
          if (tradeChartController.marketOpen.value) {
            if (!tradeChartController.isLiquidating) {
              final double sl = p.stopLoss == null || p.stopLoss == 0.0
                  ? 0.0
                  : p.stopLoss ?? 0.0;
              final double tp = p.takeProfit == null || p.takeProfit == 0.0
                  ? 0.0
                  : p.takeProfit ?? 0.0;
              c.updateSLTPValue(sl, tp);
              Get.to(() => ModifyPositionScreen(
                  sL: sl, tP: tp, trade: p, profitLoss: pl));
            }
          } else {
            FlushMessages.commonToast(
              "The market is currently closed. You cannot close or modify trades until it reopens",
              backGroundColor: colorConstants.dimGrayColor,
            );
          }
        }
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Row(
        children: [
          CustomText('XAUUSD, ',
              size: 16.sp,
              fw: FontWeight.w600,
              color: colorConstants.blackColor),
          CustomText(
            '${p.side == TradeSide.buy ? 'Buy' : 'Sell'} ${p.lots.toStringAsFixed(2)}',
            size: 12.sp,
            fw: FontWeight.w700,
            color: p.side == TradeSide.sell
                ? colorConstants.redColor
                : colorConstants.blueColor,
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colorConstants.greenColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: CustomText(
              "Executed",
              size: 12.sp,
              color: colorConstants.greenColor,
              fw: FontWeight.w600,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(p.entryPrice.toStringAsFixed(2),
                  size: 14.sp, color: colorConstants.hintTextColor),
              SizedBox(width: 5.w),
              Icon(Icons.arrow_forward,
                  size: 12.sp, color: colorConstants.iconGrayColor),
              SizedBox(width: 5.w),
              CustomText(exitPrice.toStringAsFixed(2),
                  size: 12.sp, color: colorConstants.hintTextColor),
            ],
          ),
          if (p.stopLoss != null || p.takeProfit != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                if (p.stopLoss != null && p.stopLoss != 0.0)
                  CustomText("SL: ${p.stopLoss!.toStringAsFixed(2)}",
                      size: 12.sp, color: colorConstants.redColor),
                SizedBox(
                    width: p.stopLoss == null || p.stopLoss == 0.0 ? 0.w : 8.w),
                if (p.takeProfit != null && p.takeProfit != -0.0)
                  CustomText("TP: ${p.takeProfit!.toStringAsFixed(2)}",
                      size: 12.sp, color: colorConstants.blueColor),
              ],
            ),
          ],
        ],
      ),
      trailing: CustomText(
        pl.toStringAsFixed(2),
        color: pl >= 0 ? colorConstants.blueColor : colorConstants.redColor,
        fw: FontWeight.w800,
        size: 14.sp,
      ),
    );
  }

  // Helper method to build API trade tile (from Data array) - no "Confirmed" label
  // NOTE: Not used on trade page (only shows active/running trades)
  // Kept for potential use in history section
  // ignore: unused_element
  Widget _buildConfirmedTradeTile(CloseTradesModel apiTrade) {
    final pl = apiTrade.profitLose;
    final exitPrice = apiTrade.currentPrice;
    final entryPrice = apiTrade.startPrice;
    final side = apiTrade.side.toLowerCase();
    final isBuy = side == 'buy';

    return ListTile(
      enabled: false, // Disable interaction for API trades
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Row(
        children: [
          CustomText(
            '${apiTrade.symbol.isNotEmpty ? apiTrade.symbol : 'XAUUSD'}, ',
            size: 16.sp,
            fw: FontWeight.w600,
            color: colorConstants.blackColor,
          ),
          CustomText(
            '${isBuy ? 'Buy' : 'Sell'} ${apiTrade.lots.toStringAsFixed(2)}',
            size: 12.sp,
            fw: FontWeight.w700,
            color: isBuy ? colorConstants.blueColor : colorConstants.redColor,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(entryPrice.toStringAsFixed(2),
                  size: 14.sp, color: colorConstants.hintTextColor),
              SizedBox(width: 5.w),
              Icon(Icons.arrow_forward,
                  size: 12.sp, color: colorConstants.iconGrayColor),
              SizedBox(width: 5.w),
              CustomText(exitPrice.toStringAsFixed(2),
                  size: 12.sp, color: colorConstants.hintTextColor),
            ],
          ),
          if (apiTrade.stopLoss != null || apiTrade.takeProfit != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                if (apiTrade.stopLoss != null && apiTrade.stopLoss != 0.0)
                  CustomText(
                    "SL: ${apiTrade.stopLoss!.toStringAsFixed(2)}",
                    size: 12.sp,
                    color: colorConstants.redColor,
                  ),
                SizedBox(
                    width: apiTrade.stopLoss == null || apiTrade.stopLoss == 0.0
                        ? 0.w
                        : 8.w),
                if (apiTrade.takeProfit != null && apiTrade.takeProfit != 0.0)
                  CustomText(
                    "TP: ${apiTrade.takeProfit!.toStringAsFixed(2)}",
                    size: 12.sp,
                    color: colorConstants.blueColor,
                  ),
              ],
            ),
          ],
        ],
      ),
      trailing: CustomText(
        pl.toStringAsFixed(2),
        color: pl >= 0 ? colorConstants.blueColor : colorConstants.redColor,
        fw: FontWeight.w800,
        size: 14.sp,
      ),
    );
  }
}
