import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/home_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';

class DemoBelanceDilogWidget {
  static void demoDialog(
    BuildContext context, {
    double? height,
    double? width,
    String? userId,
    String? demoBalance,
    String? server,
  }) {
    ColorConstants colorConstants = ColorConstants();
    GlobalKey<FormState> formKey = GlobalKey();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: colorConstants.primaryColor,
          child: GetBuilder<HomeController>(
            init: HomeController(),
            builder: (dashBoardController) {
              return Form(
                key: formKey,

                child: Container(
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.all(15.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  width: 358.w,
                  height: 250.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              "Add Demo Belance",
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

                        Row(
                          children: [
                            CustomText(
                              "* ",
                              size: 16.sp,
                              fw: FontWeight.w400,
                              color: colorConstants.redColor,
                            ),
                            CustomText(
                              "Amount",
                              size: 16.sp,
                              fw: FontWeight.w400,
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        CustomTextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          borderColor: colorConstants.fieldBorderColor,
                          hintText: "",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            color: colorConstants.hintTextColor,
                          ),
                          fillColor: colorConstants.fieldColor,
                          validateFunction: dashBoardController.amountValidate,
                          controller: dashBoardController.demoAmountController,
                        ),
                        SizedBox(height: 20.h),
                        Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            icon: Icon(
                              Icons.arrow_forward,
                              color: colorConstants.primaryColor,
                            ),
                            height: 40.h,
                            width: 180.w,
                            bordercircular: 10.r,
                            borderColor: Colors.transparent,
                            borderWidth: 2.sp,
                            text: "Submit",
                            textColor: colorConstants.primaryColor,
                            fontSize: 14.sp,
                            fw: FontWeight.w500,
                            boxColor: colorConstants.secondaryColor,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                if (dashBoardController.isDemoLoader == false) {
                                  dashBoardController.selectMode("Demo");
                                  dashBoardController.updateDemoBalance();
                                }
                              }
                            },
                            loader: dashBoardController.isDemoLoader,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
