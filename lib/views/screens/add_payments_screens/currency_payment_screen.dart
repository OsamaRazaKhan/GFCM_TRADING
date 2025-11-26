import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/add_payment_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class CurrencyPaymentScreen extends StatefulWidget {
  bool methodsIsEmpty;
  String? type;
  CurrencyPaymentScreen({super.key, required this.methodsIsEmpty, this.type});

  @override
  State<CurrencyPaymentScreen> createState() => _CurrencyPaymentScreenState();
}

class _CurrencyPaymentScreenState extends State<CurrencyPaymentScreen> {
  AddPaymentController addPaymentController = Get.put(AddPaymentController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.type != null) {
        addPaymentController.selectPaymentmethod(widget.type!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddPaymentController>(
      builder: (addPaymentController) {
        ColorConstants colorConstants = ColorConstants();
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
                      "Select A Currency Type",
                      size: 18.sp,
                      fw: FontWeight.w400,
                      color: colorConstants.blackColor,
                    ),
                    SizedBox(height: 10.h),
                    widget.methodsIsEmpty || widget.type == "Flat"
                        ? GestureDetector(
                          onTap: () {
                            addPaymentController.selectPaymentmethod("Flat");
                          },
                          child: Container(
                            width: 356.w,
                            padding: EdgeInsets.all(20.r),
                            decoration: BoxDecoration(
                              color: colorConstants.bottomDarkGrayCol,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.5,
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
                                          SizedBox(width: 20.w),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                  "Flat",
                                                  size: 16.sp,
                                                  fw: FontWeight.w500,
                                                  color:
                                                      colorConstants.blackColor,
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: CustomText(
                                                        "Add payment method like banks or credit cards",
                                                        size: 12.sp,
                                                        fw: FontWeight.w400,
                                                        color:
                                                            colorConstants
                                                                .hintTextColor,
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
                                    SizedBox(width: 5.w),
                                    Container(
                                      height: 20.h,
                                      width: 20.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 2.w,
                                          color: colorConstants.primaryColor,
                                        ),
                                        color:
                                            addPaymentController
                                                        .selectedPaymentMethod ==
                                                    "Flat"
                                                ? colorConstants.secondaryColor
                                                : colorConstants.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        : SizedBox(),
                    SizedBox(height: 15.h),
                    widget.methodsIsEmpty || widget.type == "Crypto"
                        ? GestureDetector(
                          onTap: () {
                            addPaymentController.selectPaymentmethod("Crypto");
                          },
                          child: Container(
                            width: 356.w,
                            padding: EdgeInsets.all(20.r),
                            decoration: BoxDecoration(
                              color: colorConstants.bottomDarkGrayCol,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.5,
                                            child: Helper.svgIcon(
                                              IconConstants.crypto,
                                              isSelected: false,
                                              isOriginalColor: true,
                                              originalColor:
                                                  colorConstants.secondaryColor,
                                              height: 30,
                                              width: 30,
                                            ),
                                          ),
                                          SizedBox(width: 20.w),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                  "Crypto",
                                                  size: 16.sp,
                                                  fw: FontWeight.w500,
                                                  color:
                                                      colorConstants.blackColor,
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: CustomText(
                                                        "Add payment method like banks or credit cards",
                                                        size: 12.sp,
                                                        fw: FontWeight.w400,
                                                        color:
                                                            colorConstants
                                                                .hintTextColor,
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
                                    SizedBox(width: 5.w),

                                    Container(
                                      height: 20.h,
                                      width: 20.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 2.w,
                                          color: colorConstants.primaryColor,
                                        ),
                                        color:
                                            addPaymentController
                                                        .selectedPaymentMethod ==
                                                    "Crypto"
                                                ? colorConstants.secondaryColor
                                                : colorConstants.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        : SizedBox(),
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
                  fontSize: 14.sp,
                  fw: FontWeight.w500,
                  boxColor: colorConstants.secondaryColor,
                  onTap: () {
                    addPaymentController.selectType("Payment Details");
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
