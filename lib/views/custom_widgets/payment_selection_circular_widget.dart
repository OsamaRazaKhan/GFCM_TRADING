import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/add_payment_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class PaymentSelectionCircularWidget extends StatelessWidget {
  PaymentSelectionCircularWidget({super.key});
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddPaymentController>(
      init: AddPaymentController(),
      builder: (addPaymentController) {
        return FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(
                child: Stack(
                  clipBehavior: Clip.none, //  allow overflow
                  alignment: Alignment.topCenter,
                  children: [
                    addPaymentController.selectedPaymentScreen ==
                            "Currency Type"
                        ? Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1.5,
                              color: colorConstants.secondaryColor,
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorConstants.secondaryColor,
                            ),
                          ),
                        )
                        : Container(
                          height: 25.h,
                          width: 25.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorConstants.bottomDarkGrayCol,
                          ),
                        ),

                    addPaymentController.selectedPaymentScreen ==
                            "Currency Type"
                        ? Positioned(
                          left: -6,
                          bottom: -25, // keep as negative if needed
                          child: CustomText(
                            "Currency Type",
                            color: colorConstants.secondaryColor,
                            size: 10.sp,
                            fw: FontWeight.w600,
                          ),
                        )
                        : SizedBox(),
                  ],
                ),
              ),
              // CustomText(
              //   "----",
              //   size: 25.sp,
              //   color: colorConstants.bottomDarkGrayCol,
              // ),
              // SizedBox(
              //   child: Stack(
              //     clipBehavior: Clip.none, //  allow overflow
              //     alignment: Alignment.topCenter,
              //     children: [
              //       addPaymentController.selectedPaymentScreen == "Payment Type"
              //           ? Container(
              //             height: 40.h,
              //             width: 40.w,
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               border: Border.all(
              //                 width: 1.5,
              //                 color: colorConstants.secondaryColor,
              //               ),
              //             ),
              //             child: Container(
              //               margin: EdgeInsets.all(5.r),
              //               decoration: BoxDecoration(
              //                 shape: BoxShape.circle,
              //                 color: colorConstants.secondaryColor,
              //               ),
              //             ),
              //           )
              //           : Container(
              //             height: 25.h,
              //             width: 25.w,
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               color: colorConstants.bottomDarkGrayCol,
              //             ),
              //           ),

              //       addPaymentController.selectedPaymentScreen == "Payment Type"
              //           ? Positioned(
              //             left: -12,
              //             bottom: -25, // keep as negative if needed
              //             child: CustomText(
              //               "Payment Type",
              //               color: colorConstants.secondaryColor,
              //               size: 10.sp,
              //               fw: FontWeight.w600,
              //             ),
              //           )
              //           : SizedBox(),
              //     ],
              //   ),
              // ),
              CustomText(
                "-------",
                size: 25.sp,
                color: colorConstants.bottomDarkGrayCol,
              ),
              SizedBox(
                child: Stack(
                  clipBehavior: Clip.none, // 👈 allow overflow
                  alignment: Alignment.topCenter,
                  children: [
                    addPaymentController.selectedPaymentScreen ==
                            "Payment Details"
                        ? Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1.5,
                              color: colorConstants.secondaryColor,
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorConstants.secondaryColor,
                            ),
                          ),
                        )
                        : Container(
                          height: 25.h,
                          width: 25.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorConstants.bottomDarkGrayCol,
                          ),
                        ),

                    addPaymentController.selectedPaymentScreen ==
                            "Payment Details"
                        ? Positioned(
                          left: -18,
                          bottom: -25, // keep as negative if needed
                          child: CustomText(
                            "Payment Details",
                            color: colorConstants.secondaryColor,
                            size: 10.sp,
                            fw: FontWeight.w600,
                          ),
                        )
                        : SizedBox(),
                  ],
                ),
              ),
              CustomText(
                "-------",
                size: 25.sp,
                color: colorConstants.bottomDarkGrayCol,
              ),
              SizedBox(
                child: Stack(
                  clipBehavior: Clip.none, //  allow overflow
                  alignment: Alignment.topCenter,
                  children: [
                    addPaymentController.selectedPaymentScreen == "Verify"
                        ? Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1.5,
                              color: colorConstants.secondaryColor,
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorConstants.secondaryColor,
                            ),
                          ),
                        )
                        : Container(
                          height: 25.h,
                          width: 25.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorConstants.bottomDarkGrayCol,
                          ),
                        ),

                    addPaymentController.selectedPaymentScreen == "Verify"
                        ? Positioned(
                          left: 8,
                          bottom: -25, // keep as negative if needed
                          child: CustomText(
                            "Verify",
                            color: colorConstants.secondaryColor,
                            size: 10.sp,
                            fw: FontWeight.w600,
                          ),
                        )
                        : SizedBox(),
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
