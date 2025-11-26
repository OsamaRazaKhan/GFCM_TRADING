import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/add_payment_controller.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/payment_selection_circular_widget.dart';
import 'package:gfcm_trading/views/screens/add_payments_screens/currency_payment_screen.dart';
import 'package:gfcm_trading/views/screens/add_payments_screens/payment_details_screen.dart';
import 'package:gfcm_trading/views/screens/add_payments_screens/verify_method_screen.dart';

class AddPaymentMainDialog {
  static void addPaymentDialog(
    BuildContext context, {
    double? height,
    double? width,
    String? userId,
    String? password,
    String? server,
    bool methodsIsEmpty = true,
    String? type,
  }) {
    ColorConstants colorConstants = ColorConstants();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: colorConstants.primaryColor,
          child: GetBuilder<AddPaymentController>(
            init: AddPaymentController(),
            builder: (addPaymentController) {
              return Container(
                clipBehavior: Clip.none,
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                width: 358.w,
                height: 732.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          "Add Payment Method",
                          size: 18.sp,
                          fw: FontWeight.w500,
                          color: colorConstants.blackColor,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: colorConstants.blackColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    PaymentSelectionCircularWidget(),
                    SizedBox(height: 15.h),
                    addPaymentController.selectedPaymentScreen ==
                            "Currency Type"
                        ? Expanded(
                            child: CurrencyPaymentScreen(
                              methodsIsEmpty: methodsIsEmpty,
                              type: type,
                            ),
                          )
                        : addPaymentController.selectedPaymentScreen ==
                                "Payment Details"
                            ? Expanded(child: PaymentDetailsScreen())
                            : Expanded(child: VerifyMethodScreen()),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
