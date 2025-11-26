import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_circular_avatar_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/screens/fund_screens/deposit_screen.dart';
import 'package:gfcm_trading/views/screens/fund_screens/payment_screen.dart';
import 'package:gfcm_trading/views/screens/fund_screens/transfer_screen.dart';
import 'package:gfcm_trading/views/screens/fund_screens/withdraw_screen.dart';

class FundsMainScreen extends StatefulWidget {
  const FundsMainScreen({super.key});

  @override
  State<FundsMainScreen> createState() => _FundsMainScreenState();
}

class _FundsMainScreenState extends State<FundsMainScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  ColorConstants colorConstants = ColorConstants();
  TransferController transferController = Get.put(TransferController());
  ColorConstants colorConstant = ColorConstants();

  late TabController _tabController;
  bool _isTabSwitching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transferController.getUserData();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Set loading state when tab is changing
      if (mounted) {
        setState(() {
          _isTabSwitching = true;
        });
      }
    } else {
      // Tab change is complete, add delay to allow proper rendering
      Future.delayed(Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _isTabSwitching = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  double _calculateTabBarHeight() {
    // Get the current tab index
    final currentIndex = _tabController.index;

    // Calculate height based on selected tab and content
    if (currentIndex == 0) {
      // Deposit tab
      if (transferController.selectedDepositMethod == null) {
        return 180.h + 20.h; // Dropdown + 20px buffer
      } else {
        final selectedType =
            transferController.selectedDepositMethod?.toLowerCase();
        List<dynamic> filteredMethods = [];
        if (selectedType == "all") {
          filteredMethods = transferController.gfcmPaymentMethod;
        } else {
          filteredMethods = transferController.gfcmPaymentMethod
              .where((method) =>
                  (method.paymenttype?.toLowerCase() ?? "") == selectedType)
              .toList();
        }

        if (filteredMethods.isEmpty) {
          return 200.h + 20.h; // No methods message + 20px buffer
        } else {
          // Calculate height based on actual card types
          // Use more accurate heights without extra padding
          double totalHeight = 0;
          for (var method in filteredMethods) {
            final isBank = (method.paymenttype?.toLowerCase() ?? "") == "bank";
            // Bank cards: ~580h (without extra), Crypto cards: ~480h (without extra)
            totalHeight += isBank ? 450.h : 350.h;
          }

          // Add header section height (Select Payment Type container ~90h + Deposit Methods title ~50h)
          totalHeight += 140.h; // Header section

          // Add spacing between cards (15h between each)
          if (filteredMethods.length > 1) {
            totalHeight += (filteredMethods.length - 1) * 15.h;
          }

          // Add only 20px buffer as requested
          return totalHeight + 20.h;
        }
      }
    } else if (currentIndex == 1) {
      // Transfer tab
      return 550.h + 20.h; // + 20px buffer
    } else if (currentIndex == 2) {
      // Withdraw tab
      return 400.h + 20.h; // + 20px buffer
    } else if (currentIndex == 3) {
      // Payment tab
      if (transferController.activePaymentMethodsList.isEmpty) {
        return 200.h + 20.h; // + 20px buffer
      } else {
        // Each payment method card is approximately 200-250h
        final estimatedHeight =
            (transferController.activePaymentMethodsList.length * 220.h) +
                150.h;
        return estimatedHeight + 20.h; // + 20px buffer
      }
    }

    // Default fallback
    return 600.h + 20.h; // + 20px buffer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorConstants.blackColor),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: CustomText(
          "Funds",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
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
          SizedBox(width: 10.w),
        ],
      ),
      body: GetBuilder<TransferController>(
        builder: (transferController) {
          return Container(
            width: Get.width,
            padding: EdgeInsets.only(
              left: 10.r,
              right: 10.r,
              top: 10.h,
              bottom: 10.h,
            ),
            margin: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: colorConstants.bottomDarkGrayCol,
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  transferController.selectedTabValue == "Withdraw"
                      ? SizedBox()
                      : Row(
                          children: [
                            CustomCircularAvatarWidget(
                              height: 50.h,
                              width: 50.h,
                              boxColor: colorConstants.secondaryColor,
                              isAsset: true,
                              svgIcon: Transform.scale(
                                scale: 0.5,
                                child: Helper.svgIcon(
                                  IconConstants.fundsSvg,
                                  isSelected: false,
                                  isOriginalColor: true,
                                  originalColor: colorConstants.primaryColor,
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    transferController.isGetData
                                        ? Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Center(
                                              child: SizedBox(
                                                width: 10, // adjust size
                                                height: 10, // adjust size
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth:
                                                      2, // thickness of the line
                                                  color: colorConstants
                                                      .secondaryColor,
                                                ),
                                              ),
                                            ),
                                          )
                                        : CustomText(
                                            (double.tryParse(
                                                  transferController
                                                          .userData?['balance']
                                                          .toString() ??
                                                      "0",
                                                )?.toStringAsFixed(2)) ??
                                                "0.0",
                                            size: 14.sp,
                                            fw: FontWeight.w700,
                                            color: colorConstants.blackColor,
                                          ),
                                    SizedBox(width: 4.w),
                                    CustomText(
                                      "USD",
                                      size: 12.sp,
                                      fw: FontWeight.w400,
                                      color: colorConstants.hintTextColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3.h),
                                CustomText(
                                  "Trade",
                                  size: 12.sp,
                                  fw: FontWeight.w400,
                                  color: colorConstants.blackColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                  SizedBox(
                    height: transferController.selectedTabValue == "Withdraw"
                        ? 0
                        : 25.h,
                  ),
                  Row(
                    children: [
                      CustomCircularAvatarWidget(
                        height: 50.h,
                        width: 50.h,
                        boxColor: colorConstants.secondaryColor,
                        isAsset: true,
                        svgIcon: Transform.scale(
                          scale: 0.5,
                          child: Helper.svgIcon(
                            IconConstants.partnerShipSvg,
                            isSelected: false,
                            isOriginalColor: true,
                            originalColor: colorConstants.primaryColor,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              transferController.isGetData
                                  ? Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Center(
                                        child: SizedBox(
                                          width: 10, // adjust size
                                          height: 10, // adjust size
                                          child: CircularProgressIndicator(
                                            strokeWidth:
                                                2, // thickness of the line
                                            color:
                                                colorConstants.secondaryColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  : CustomText(
                                      (double.tryParse(
                                            transferController
                                                    .userData?['partner']
                                                    .toString() ??
                                                "0",
                                          )?.toStringAsFixed(2)) ??
                                          "0.0",
                                      size: 14.sp,
                                      fw: FontWeight.w700,
                                      color: colorConstants.blackColor,
                                    ),
                              SizedBox(width: 4.w),
                              CustomText(
                                "USD",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          CustomText(
                            "Partner",
                            size: 12.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  Row(
                    children: [
                      CustomCircularAvatarWidget(
                        height: 50.h,
                        width: 50.h,
                        boxColor: colorConstants.secondaryColor,
                        isAsset: true,
                        svgIcon: Transform.scale(
                          scale: 0.5,
                          child: Helper.svgIcon(
                            IconConstants.socialSvg,
                            isSelected: false,
                            isOriginalColor: true,
                            originalColor: colorConstants.primaryColor,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              transferController.isGetData
                                  ? Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Center(
                                        child: SizedBox(
                                          width: 10, // adjust size
                                          height: 10, // adjust size
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2, // thickness of the
                                            color:
                                                colorConstants.secondaryColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  : CustomText(
                                      (double.tryParse(
                                            transferController
                                                    .userData?['social']
                                                    .toString() ??
                                                "0",
                                          )?.toStringAsFixed(2)) ??
                                          "0.0",
                                      size: 14.sp,
                                      fw: FontWeight.w700,
                                      color: colorConstants.blackColor,
                                    ),
                              SizedBox(width: 4.w),
                              CustomText(
                                "USD",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          CustomText(
                            "Social",
                            size: 12.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  Row(
                    children: [
                      CustomCircularAvatarWidget(
                        height: 50.h,
                        width: 50.h,
                        boxColor: colorConstants.secondaryColor,
                        isAsset: true,
                        svgIcon: Transform.scale(
                          scale: 0.5,
                          child: Helper.svgIcon(
                            IconConstants.fundingSvg,
                            isSelected: false,
                            isOriginalColor: true,
                            originalColor: colorConstants.primaryColor,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              transferController.isGetData
                                  ? Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Center(
                                        child: SizedBox(
                                          width: 10, // adjust size
                                          height: 10, // adjust size
                                          child: CircularProgressIndicator(
                                            strokeWidth:
                                                2, // thickness of the line
                                            color:
                                                colorConstants.secondaryColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  : CustomText(
                                      (double.tryParse(
                                            transferController
                                                    .userData?['wallet']
                                                    .toString() ??
                                                "0",
                                          )?.toStringAsFixed(2)) ??
                                          "0.0",
                                      size: 14.sp,
                                      fw: FontWeight.w700,
                                      color: colorConstants.blackColor,
                                    ),
                              SizedBox(width: 4.w),
                              CustomText(
                                "USD",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          CustomText(
                            "Wallet",
                            size: 12.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.blackColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 50.h),
                  Material(
                    color: colorConstants.secondaryColor, // golden background
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // rounded corners
                    child: TabBar(
                      onTap: (_) => FocusScope.of(
                        context,
                      ).unfocus(), // tap -> close keyboard
                      controller: _tabController,

                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 2.w,
                          color: colorConstants.blackColor,
                        ),
                        insets: EdgeInsets.symmetric(vertical: 8),
                      ),

                      tabs: [
                        Tab(
                          child: FittedBox(
                            child: CustomText(
                              "Deposit",
                              color: colorConstants.blackColor,
                              size: 12.sp,
                              fw: FontWeight.w700,
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            child: CustomText(
                              "Transfer",
                              color: colorConstants.blackColor,
                              size: 12.sp,
                              fw: FontWeight.w700,
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            child: CustomText(
                              "Withdraw",
                              color: colorConstants.blackColor,
                              size: 12.sp,
                              fw: FontWeight.w700,
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            child: CustomText(
                              "Payment",
                              color: colorConstants.blackColor,
                              size: 12.sp,
                              fw: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Builder(
                    builder: (context) {
                      // Show loader when switching tabs
                      if (_isTabSwitching) {
                        return Container(
                          height: 400.h,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorConstants.secondaryColor,
                          ),
                        );
                      }

                      // Use AnimatedBuilder to listen to tab changes
                      return AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, child) {
                          return SizedBox(
                            height: _calculateTabBarHeight(),
                            child: TabBarView(
                              controller: _tabController,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                DepositScreen(),
                                TransferScreen(),
                                WithdrawScreen(),
                                PaymentScreen(),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
