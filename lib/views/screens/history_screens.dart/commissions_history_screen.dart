import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/nav_controller.dart';
import 'package:gfcm_trading/utils/helpers/dede_time_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CommissionsHistoryScreen extends StatefulWidget {
  const CommissionsHistoryScreen({super.key});

  @override
  State<CommissionsHistoryScreen> createState() =>
      _CommissionsHistoryScreenState();
}

class _CommissionsHistoryScreenState extends State<CommissionsHistoryScreen> {
  ColorConstants colorConstants = ColorConstants();
  final NavController navController = Get.put(NavController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NavController>().clearCommisionsDate();
      Get.find<NavController>().getCommissionsHistory();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Get.find<NavController>().getCommissionsHistory(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return GetBuilder<NavController>(
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
                        itemCount: navController.commissionsList.length +
                            (navController.hasCommissionMoreData
                                ? 1
                                : 0), // +1 for loader
                        itemBuilder: (context, index) {
                          if (index < navController.commissionsList.length) {
                            final commission =
                                navController.commissionsList[index];
                            if (navController.commissionsList.isEmpty &&
                                !navController.iCommissionLoadingMore) {
                              return Center(
                                child: CustomText(
                                  "No commissions found",
                                  color: colorConstants.hintTextColor,
                                ),
                              );
                            }
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: colorConstants.bottomDarkGrayCol,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Date + Status ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        DedetimeHelper.dateTimeConverter(
                                          commission.createdOn ??
                                              "2025-08-29T11:03:13.000Z",
                                        ),
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.hintTextColor,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (commission.status
                                                      ?.toLowerCase() ==
                                                  "approved")
                                              ? colorConstants.greenColor
                                                  .withOpacity(0.2)
                                              : (commission.status
                                                          ?.toLowerCase() ==
                                                      "pending")
                                                  ? Colors.orange.withOpacity(
                                                      0.2,
                                                    )
                                                  : colorConstants.redColor
                                                      .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            5.r,
                                          ),
                                        ),
                                        child: CustomText(
                                          commission.status?.capitalize ??
                                              "Unknown",
                                          size: 11.sp,
                                          fw: FontWeight.w600,
                                          color: (commission.status
                                                      ?.toLowerCase() ==
                                                  "approved")
                                              ? colorConstants.greenColor
                                              : (commission.status
                                                          ?.toLowerCase() ==
                                                      "pending")
                                                  ? Colors.orange
                                                  : colorConstants.redColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Amount: ${commission.amount ?? '0'}",
                                        size: 14.sp,
                                        fw: FontWeight.w600,
                                        color: colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        commission.type?.capitalize ?? "N/A",
                                        size: 13.sp,
                                        fw: FontWeight.w500,
                                        color: colorConstants.hintTextColor,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),

                                  // --- User Info ---
                                  Divider(color: Colors.grey.withOpacity(0.3)),
                                  SizedBox(height: 6.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: CustomText(
                                          commission.fromUserFullname ?? '',
                                          size: 13.sp,
                                          fw: FontWeight.w500,
                                          color: colorConstants.blackColor,
                                        ),
                                      ),
                                      CustomText(
                                        commission.fromid ?? '',
                                        size: 11.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.hintTextColor,
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: commission.current == "true",
                                    child: Column(
                                      children: [
                                        // SizedBox(height: 10.h),
                                        // CustomText(
                                        //   "Your referral has utilized 60% of their allotted lots. Please click Submit to apply your commission.",
                                        //   size: 12.sp,
                                        //   fw: FontWeight.w400,
                                        //   color: colorConstants.blackColor,
                                        // ),
                                        // SizedBox(height: 7.h),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.end,
                                        //   children: [
                                        //     GetBuilder<NavController>(
                                        //       id: 'commission_$index', // unique ID per item
                                        //       builder: (controller) {
                                        //         return CustomButton(
                                        //           verticalPadding: controller
                                        //                           .isSubmitMap[
                                        //                       'commission_$index'] ==
                                        //                   true
                                        //               ? 2.h
                                        //               : 0,
                                        //           horizontalPadding: controller
                                        //                           .isSubmitMap[
                                        //                       'commission_$index'] ==
                                        //                   true
                                        //               ? 25.w
                                        //               : 0,
                                        //           height: 30.h,
                                        //           width: 80.w,
                                        //           bordercircular: 5.r,
                                        //           borderColor:
                                        //               Colors.transparent,
                                        //           borderWidth: 2.sp,
                                        //           text: "Submit",
                                        //           textColor: colorConstants
                                        //               .primaryColor,
                                        //           fontSize: 11.sp,
                                        //           fw: FontWeight.w500,
                                        //           boxColor: colorConstants
                                        //               .secondaryColor,
                                        //           onTap: () {
                                        //             controller.isSubmitMap[
                                        //                         'commission_$index'] ==
                                        //                     true
                                        //                 ? null
                                        //                 : navController
                                        //                     .updateReferralBalance(
                                        //                     commission.amount ??
                                        //                         "0",
                                        //                     'commission_$index',
                                        //                     commission.id ?? 0,
                                        //                   );
                                        //           },
                                        //           loader: controller
                                        //                       .isSubmitMap[
                                        //                   'commission_$index'] ==
                                        //               true,
                                        //         );
                                        //       },
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
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
}
