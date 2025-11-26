import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/add_payment_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class PaymentTypeScreen extends StatefulWidget {
  const PaymentTypeScreen({super.key});

  @override
  State<PaymentTypeScreen> createState() => _PaymentTypeScreenState();
}

class _PaymentTypeScreenState extends State<PaymentTypeScreen> {
  @override
  Widget build(BuildContext context) {
    ColorConstants colorConstants = ColorConstants();
    return GetBuilder<AddPaymentController>(
      init: AddPaymentController(),
      builder: (addPaymentController) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(height: 60.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Select A Payment Type",
                      size: 18.sp,
                      fw: FontWeight.w400,
                      color: colorConstants.blackColor,
                    ),
                    SizedBox(height: 5.h),
                    CustomText(
                      "Please Select your preferred payment type",
                      size: 12.sp,
                      fw: FontWeight.w400,
                      color: colorConstants.hintTextColor,
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: 160.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: colorConstants.bottomDarkGrayCol,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 1.5,
                            child: Helper.svgIcon(
                              addPaymentController.selectedPaymentMethod ==
                                      "Flat"
                                  ? IconConstants.bankSvg
                                  : IconConstants.usdTether,
                              isSelected: false,
                              isOriginalColor: true,
                              originalColor:
                                  addPaymentController.selectedPaymentMethod ==
                                          "Flat"
                                      ? colorConstants.secondaryColor
                                      : colorConstants.tealColor,
                              height: 30,
                              width: 30,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          CustomText(
                            addPaymentController.selectedPaymentMethod == "Flat"
                                ? "Bank"
                                : "USDT Tether",
                            size: 16.sp,
                            fw: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: CustomButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 20.sp,
                    color: colorConstants.primaryColor,
                  ),
                  height: 44.h,
                  width: 200.w,
                  bordercircular: 8.r,
                  borderColor: Colors.transparent,
                  textColor: colorConstants.primaryColor,
                  borderWidth: 2.sp,
                  text: "Next",
                  fontSize: 16.sp,
                  fw: FontWeight.w500,
                  boxColor: colorConstants.secondaryColor,
                  onTap: () {
                    addPaymentController.selectType("Payment Details");
                  },
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 20.h,
                    color: colorConstants.blueColor,
                  ),
                  TextButton(
                    onPressed: () {
                      addPaymentController.selectType("Currency Type");
                    },
                    child: CustomText(
                      "Back To Previous",
                      size: 14.sp,
                      fw: FontWeight.w500,
                      color: colorConstants.blueColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
