import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/transaction_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class WalletTrasaction extends StatefulWidget {
  const WalletTrasaction({super.key});
  @override
  State<WalletTrasaction> createState() => _WalletTrasactionState();
}

class _WalletTrasactionState extends State<WalletTrasaction> {
  ColorConstants colorConstants = ColorConstants();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<TransactionController>().clearDate();
      Get.find<TransactionController>().getWalletTrasection();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Get.find<TransactionController>().getWalletTrasection(loadMore: true);
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
    return GetBuilder<TransactionController>(
      init: TransactionController(),
      builder: (transactionController) {
        return Container(
          padding: EdgeInsets.all(15.r),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          transactionController.selectFilter("wallet");
                        },
                        child: Transform.scale(
                          scale: 0.6,
                          child: Helper.svgIcon(
                            IconConstants.filterSvg,
                            isSelected: false,
                            isOriginalColor: true,
                            originalColor:
                                transactionController.isWalletFilter
                                    ? colorConstants.blackColor
                                    : colorConstants.hintTextColor,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomText(
                        "Filter",
                        size: 14.sp,
                        fw: FontWeight.w500,
                        color:
                            transactionController.isWalletFilter
                                ? colorConstants.blackColor
                                : colorConstants.hintTextColor,
                      ),
                    ],
                  ),
                  Visibility(
                    visible: transactionController.isWalletFilter,
                    child: CustomButton(
                      height: 27.h,
                      width: 85.w,
                      bordercircular: 3.r,
                      borderColor: Colors.transparent,
                      borderWidth: 2.sp,
                      text: "Clear Filter",
                      textColor: colorConstants.redColor,
                      boxColor: colorConstants.bottomDarkGrayCol,
                      onTap: () {
                        if (transactionController.fromDate != null ||
                            transactionController.toDate != null) {
                          Get.find<TransactionController>().clearDate();
                          Get.find<TransactionController>()
                              .getWalletTrasection();
                        }
                      },
                      fontSize: 11.sp,
                      fw: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Visibility(
                visible: transactionController.isWalletFilter,
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: colorConstants.bottomDarkGrayCol,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          transactionController.selectDate(context, "wallet");
                        },
                        leading: CustomText(
                          "Select Date Range",
                          size: 14.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.hintTextColor,
                        ),
                        trailing: Transform.scale(
                          scale: 0.7,
                          child: Helper.svgIcon(
                            IconConstants.dateSvg,
                            isSelected: false,
                            isOriginalColor: true,
                            originalColor: colorConstants.hintTextColor,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: transactionController.isWalletFilter ? 20.h : 0.h,
              ),

              Expanded(
                child: SizedBox(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        transactionController.walletTrasectionsList.length +
                        (transactionController.walletHasMoreData
                            ? 1
                            : 0), // +1 for loader
                    itemBuilder: (context, index) {
                      if (index <
                          transactionController.walletTrasectionsList.length) {
                        final walletTrasactions =
                            transactionController.walletTrasectionsList[index];
                        if (transactionController
                                .walletTrasectionsList
                                .isEmpty &&
                            !transactionController.walletIsLoadingMore) {
                          return Center(
                            child: CustomText(
                              "No wallet trasections found",
                              color: colorConstants.hintTextColor,
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ListTile(
                              title: CustomText(
                                transactionController.toCamel(
                                  walletTrasactions.transactiontype ??
                                      "default",
                                ),
                                size: 18.sp,
                                fw: FontWeight.w500,
                                color: colorConstants.blackColor,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    transactionController.formatWalletDate(
                                      walletTrasactions.datetime ??
                                          "2025-08-29T11:03:13.000Z",
                                    ),
                                    size: 14.sp,
                                    fw: FontWeight.w500,
                                    color: colorConstants.hintTextColor,
                                  ),

                                  Row(
                                    children: [
                                      CustomText(
                                        "Tex ID",
                                        size: 14.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.hintTextColor,
                                      ),
                                      SizedBox(width: 3.w),
                                      CustomText(
                                        walletTrasactions.id.toString(),
                                        size: 14.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.south_west,
                                color: colorConstants.redColor,
                                size: 25.sp,
                              ),
                            ),
                            SizedBox(height: 15.h),

                            FittedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  walletTrasactions.transactiontype ==
                                          "Withdraw"
                                      ? Row(
                                        children: [
                                          Transform.scale(
                                            scale: 0.7.sp,

                                            child: Helper.svgIcon(
                                              IconConstants.fundingSvg,
                                              isSelected: false,
                                              isOriginalColor: true,
                                              originalColor:
                                                  colorConstants.blackColor,
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          CustomText(
                                            "Funding",
                                            size: 16.sp,
                                            fw: FontWeight.w500,
                                            color: colorConstants.blackColor,
                                          ),
                                        ],
                                      )
                                      : Row(
                                        children: [
                                          CustomImage(
                                            height: 45.h,
                                            width: 45.w,
                                            image: AssetConstants.gfcmLogo,
                                          ),
                                          SizedBox(width: 10.w),
                                          CustomText(
                                            "GFCM",
                                            size: 16.sp,
                                            fw: FontWeight.w500,
                                            color: colorConstants.blackColor,
                                          ),
                                        ],
                                      ),
                                  SizedBox(width: 20.w),

                                  Transform.scale(
                                    scale: 0.5,
                                    child: Helper.svgIcon(
                                      IconConstants.forwardSvg,
                                      isSelected: false,
                                      isOriginalColor: true,
                                      originalColor:
                                          colorConstants.hintTextColor,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.6.sp,
                                        child: Helper.svgIcon(
                                          IconConstants.bankSvg,
                                          isSelected: false,
                                          isOriginalColor: true,
                                          originalColor:
                                              colorConstants.blackColor,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      CustomText(
                                        walletTrasactions.transactiontype ==
                                                "Deposit"
                                            ? "Trade Account"
                                            : walletTrasactions
                                                    .transactiontype ==
                                                "Referral Deposit"
                                            ? "Partner Account"
                                            : "${transactionController.toCamel(walletTrasactions.wallet ?? "Default")} Account(USD)",
                                        size: 16.sp,
                                        fw: FontWeight.w500,
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8.w,
                                      height: 8.h,
                                      decoration: BoxDecoration(
                                        color:
                                            walletTrasactions.status ==
                                                    "Confirmed"
                                                ? colorConstants.greenColor
                                                : colorConstants.redColor,

                                        borderRadius: BorderRadius.circular(
                                          100.r,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    CustomText(
                                      walletTrasactions.status,
                                      size: 16.sp,
                                      fw: FontWeight.w400,
                                      color: colorConstants.blackColor,
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    CustomText(
                                      walletTrasactions.transactiontype ==
                                                  "Deposit" ||
                                              walletTrasactions
                                                      .transactiontype ==
                                                  "Referral Deposit"
                                          ? walletTrasactions.amount.toString()
                                          : "-${walletTrasactions.amount}",
                                      size: 16.sp,
                                      fw: FontWeight.w700,
                                      color:
                                          walletTrasactions.transactiontype ==
                                                      "Deposit" ||
                                                  walletTrasactions
                                                          .transactiontype ==
                                                      "Referral Deposit"
                                              ? colorConstants.greenColor
                                              : colorConstants.redColor,
                                    ),
                                    CustomText(
                                      "USD",
                                      size: 12.sp,
                                      fw: FontWeight.w400,
                                      color: colorConstants.hintTextColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              width: 240.w,
                              decoration: BoxDecoration(
                                color: colorConstants.redColor,
                                border: Border.all(
                                  width: 0.5,
                                  color: colorConstants.redColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
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
              ),
            ],
          ),
        );
      },
    );
  }
}
