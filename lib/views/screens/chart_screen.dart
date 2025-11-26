// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/chart_indicators.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_dropdown_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/reuseable_drawer_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/top_trade_panel.dart';
import 'package:gfcm_trading/views/screens/market_sl_tp.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> with RouteAware {
  late FocusScopeNode _focusScopeNode;
  final TradeChartController controller = Get.find<TradeChartController>();

  @override
  void initState() {
    super.initState();
    _focusScopeNode = FocusScopeNode();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      child: Scaffold(
        drawer: ReuseableDrawerWidget(),
        appBar: AppBar(
          backgroundColor: colorConstants.primaryColor,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // now works
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
              );
            },
          ),
          title: Row(
            children: [
              CustomText("Charts", size: 20.sp, fw: FontWeight.w500),
              SizedBox(width: 5.w),
            ],
          ),
          actions: [
            // SL/TP Order Button
            Obx(() {
              final isConnected = controller.isConnectedToInterNet.value;
              return GestureDetector(
                onTap: () {
                  if (isConnected) {
                    Get.to(() => const SLTPOrderScreen());
                  } else {
                    FlushMessages.commonToast(
                      "Please check your internet connection",
                      backGroundColor: colorConstants.dimGrayColor,
                    );
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10.w),
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: isConnected 
                        ? colorConstants.secondaryColor 
                        : colorConstants.secondaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.tune,
                    color: colorConstants.whiteColor,
                    size: 20.sp,
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () {
                if (controller.isConnectedToInterNet.value) {
                  controller.showHideSellBuy();
                }
              },
              child: Container(
                height: 20.h,
                width: 30.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.r),
                  gradient: LinearGradient(
                    colors: controller.isConnectedToInterNet.value
                        ? [
                            colorConstants.redColor,
                            colorConstants.blueColor,
                          ]
                        : [
                            colorConstants.redColor.withOpacity(
                              0.6,
                            ), // dim red
                            colorConstants.blueColor.withOpacity(
                              0.6,
                            ), // dim blue
                          ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.circle,
                    color: colorConstants.whiteColor,
                    size: 10.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
          ],
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // === Fullscreen Chart (never resizes) ===
              Positioned.fill(
                child: Obx(() {
                  return !controller.isConnectedToInterNet.value &&
                          !controller.isWebViewInitialized.value
                      ? Padding(
                          padding: EdgeInsets.all(10.r),
                          child: CustomEmptyScreenMessage(
                            icon: Icon(
                              Icons.cloud_off,
                              size: 80.sp,
                              color: colorConstants.hintTextColor,
                            ),
                            headText: "Market Data Not Loaded",
                            subtext:
                                "Something went wrong while loading the chart. Please refresh or try again later",
                            onTap: () {
                              controller.checkInternet();
                            },
                          ),
                        )
                      : WebViewWidget(controller: controller.webViewController);
                }),
              ),

              // === Sliding Top Panel ===
              Obx(() {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  top: controller.isShowSellBuy.value
                      ? 0
                      : -200, // slide up/down
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      TopTradePanel(),
                      ChartIndicators(
                        spread: controller.spread.value,
                        lastPrice: controller.lastPrice.value,
                        volume: controller.volume.value,
                      ),
                      /*-----------------------------------------------------------------*/
                      /*           These are symbols we can select(Future update)        */
                      /*-----------------------------------------------------------------*/
                      // TickerSelector(onSymbolSelected: controller.changeSymbol),
                      // SizedBox(height: 5.h),
                    ],
                  ),
                );
              }),

            ],
          ),
        ),
      ),
    );
  }
}

// class ChartsScreen extends StatefulWidget {
//   const ChartsScreen({super.key});

//   @override
//   State<ChartsScreen> createState() => _ChartsScreenState();
// }

// class _ChartsScreenState extends State<ChartsScreen> with RouteAware {
//   late FocusScopeNode _focusScopeNode;
//   final TradeChartController controller = Get.find<TradeChartController>();

//   @override
//   void initState() {
//     super.initState();
//     _focusScopeNode = FocusScopeNode();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FocusScope(
//       node: _focusScopeNode,
//       child: Scaffold(
//         drawer: ReuseableDrawerWidget(),
//         appBar: AppBar(
//           backgroundColor: colorConstants.primaryColor,
//           leading: Builder(
//             builder: (BuildContext context) {
//               return IconButton(
//                 onPressed: () {
//                   Scaffold.of(context).openDrawer(); // now works
//                 },
//                 icon: Transform.scale(
//                   scale: 0.6,
//                   child: Helper.svgIcon(
//                     IconConstants.drawarSvg,
//                     isSelected: false,
//                     isOriginalColor: true,
//                     originalColor: colorConstants.blackColor,
//                     height: 30,
//                     width: 30,
//                   ),
//                 ),
//               );
//             },
//           ),
//           title: Row(
//             children: [
//               CustomText("Charts", size: 20.sp, fw: FontWeight.w500),
//               SizedBox(width: 5.w),
//             ],
//           ),
//           actions: [
//             GestureDetector(
//               onTap: () {
//                 if (controller.isConnectedToInterNet.value) {
//                   controller.showHideSellBuy();
//                 }
//               },
//               child: Container(
//                 height: 20.h,
//                 width: 30.w,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(2.r),
//                   gradient: LinearGradient(
//                     colors:
//                         controller.isConnectedToInterNet.value
//                             ? [
//                               colorConstants.redColor,
//                               colorConstants.blueColor,
//                             ]
//                             : [
//                               colorConstants.redColor.withOpacity(
//                                 0.6,
//                               ), // dim red
//                               colorConstants.blueColor.withOpacity(
//                                 0.6,
//                               ), // dim blue
//                             ],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   ),
//                 ),
//                 child: Center(
//                   child: Icon(
//                     Icons.circle,
//                     color: colorConstants.whiteColor,
//                     size: 10.sp,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 10.w),
//           ],
//         ),
//         backgroundColor:
//             Theme.of(context).brightness == Brightness.dark
//                 ? Colors.black
//                 : Colors.white,
//         body: SafeArea(
//           child: Stack(
//             children: [
//               //=== Fullscreen Chart (never resizes) ===
//               Positioned.fill(
//                 child: Obx(() {
//                   return !controller.isConnectedToInterNet.value &&
//                           !controller.isWebViewInitialized.value
//                       ? Padding(
//                         padding: EdgeInsets.all(10.r),
//                         child: CustomEmptyScreenMessage(
//                           icon: Icon(
//                             Icons.cloud_off,
//                             size: 80.sp,
//                             color: colorConstants.hintTextColor,
//                           ),
//                           headText: "Market Data Not Loaded",
//                           subtext:
//                               "Something went wrong while loading the chart. Please refresh or try again later",
//                           onTap: () {
//                             controller.checkInternet();
//                           },
//                         ),
//                       )
//                       : controller.createPersistentWebView();
//                 }),
//               ),

//               // === Sliding Top Panel ===
//               Obx(() {
//                 return AnimatedPositioned(
//                   duration: Duration(milliseconds: 400),
//                   curve: Curves.easeInOut,
//                   top:
//                       controller.isShowSellBuy.value
//                           ? 0
//                           : -200, // slide up/down
//                   left: 0,
//                   right: 0,
//                   child: Column(
//                     children: [
//                       TopTradePanel(),
//                       ChartIndicators(
//                         spread: controller.spread.value,
//                         lastPrice: controller.lastPrice.value,
//                         volume: controller.volume.value,
//                       ),
//                       /*-----------------------------------------------------------------*/
//                       /*           These are symbols we can select(Future update)        */
//                       /*-----------------------------------------------------------------*/
//                       // TickerSelector(onSymbolSelected: controller.changeSymbol),
//                       // SizedBox(height: 5.h),
//                     ],
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//latest one---

//old one
// class ChartsScreen extends StatefulWidget {
//   const ChartsScreen({super.key});

//   @override
//   State<ChartsScreen> createState() => _ChartsScreenState();
// }

// class _ChartsScreenState extends State<ChartsScreen> with RouteAware {
//   late FocusScopeNode _focusScopeNode;

//   final TradeChartController controller = Get.find<TradeChartController>();

//   @override
//   void initState() {
//     super.initState();
//     _focusScopeNode = FocusScopeNode();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FocusScope(
//       node: _focusScopeNode,
//       child: Scaffold(
//         drawer: ReuseableDrawerWidget(),
//         appBar: AppBar(
//           leading: Builder(
//             builder: (BuildContext context) {
//               return IconButton(
//                 onPressed: () {
//                   Scaffold.of(context).openDrawer(); // now works
//                 },
//                 icon: Transform.scale(
//                   scale: 0.6,
//                   child: Helper.svgIcon(
//                     IconConstants.drawarSvg,
//                     isSelected: false,
//                     isOriginalColor: true,
//                     originalColor: colorConstants.blackColor,
//                     height: 30,
//                     width: 30,
//                   ),
//                 ),
//               );
//             },
//           ),

//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CustomText("Charts", size: 20.sp, fw: FontWeight.w500),
//                   SizedBox(width: 5.w),
//                 ],
//               ),
//             ],
//           ),
//           actions: [
//             GestureDetector(
//               onTap: () {
//                 controller.showHideSellBuy();
//               },
//               child: Container(
//                 height: 20.h,
//                 width: 30.w,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(2.r),
//                   gradient: LinearGradient(
//                     colors: [colorConstants.redColor, colorConstants.blueColor],
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                   ),
//                 ),
//                 child: Center(
//                   child: Icon(
//                     Icons.circle, // clock icon
//                     color: colorConstants.whiteColor,
//                     size: 10.sp,
//                   ),
//                 ),
//               ),
//             ),

//             SizedBox(width: 10.w),
//           ],
//         ),
//         backgroundColor:
//             Theme.of(context).brightness == Brightness.dark
//                 ? Colors.black
//                 : Colors.white,
//         body: SafeArea(
//           child: Column(
//             children: [
//               // Top Trade Panel with smooth expand/collapse
//               Obx(() {
//                 return AnimatedSize(
//                   duration: Duration(milliseconds: 400),
//                   curve: Curves.easeInOut,
//                   alignment: Alignment.topCenter,
//                   child:
//                       controller.isShowSellBuy.value
//                           ? TopTradePanel()
//                           : SizedBox.shrink(),
//                 );
//               }),

//               SizedBox(height: 8),

//               // Chart Indicators with smooth expand/collapse
//               Obx(() {
//                 return AnimatedSize(
//                   duration: Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                   alignment: Alignment.topCenter,
//                   child:
//                       controller.isShowSellBuy.value
//                           ? ChartIndicators(
//                             spread: controller.spread.value,
//                             lastPrice: controller.lastPrice.value,
//                             volume: controller.volume.value,
//                           )
//                           : SizedBox.shrink(),
//                 );
//               }),

//               // TickerSelector(onSymbolSelected: controller.changeSymbol),
//               // SizedBox(height: 5.h),
//               Obx(() {
//                 return Expanded(
//                   child:
//                       controller.lastPrice.value == 0.0 ||
//                               !controller.isConnectedToInterNet.value
//                           ? Padding(
//                             padding: EdgeInsets.all(10.r),
//                             child: CustomEmptyScreenMessage(
//                               icon: Icon(
//                                 Icons.cloud_off,
//                                 size: 80.sp,
//                                 color: colorConstants.hintTextColor,
//                               ),
//                               headText: "Market Data Not Loaded",
//                               subtext:
//                                   "Something went wrong while loading the chart. Please refresh or try again later",
//                               onTap: () {
//                                 controller.checkInternet();
//                               },
//                             ),
//                           )
//                           : WebViewWidget(
//                             controller: controller.webViewController,
//                           ),
//                 );
//               }),

//               // Animated top panel overlay
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
