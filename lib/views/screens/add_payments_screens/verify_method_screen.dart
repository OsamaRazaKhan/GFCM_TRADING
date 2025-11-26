import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/add_payment_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:path/path.dart' as path;

class VerifyMethodScreen extends StatefulWidget {
  const VerifyMethodScreen({super.key});

  @override
  State<VerifyMethodScreen> createState() => _VerifyMethodScreenState();
}

class _VerifyMethodScreenState extends State<VerifyMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddPaymentController>(
      init: AddPaymentController(),
      builder: (addPaymentController) {
        ColorConstants colorConstants = ColorConstants();
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        "Verification",
                        size: 18.sp,
                        fw: FontWeight.w400,
                        color: colorConstants.blackColor,
                      ),
                      SizedBox(height: 5.h),
                      CustomText(
                        "Please upload a screenshot of your wallet address",
                        size: 12.sp,
                        fw: FontWeight.w400,
                        color: colorConstants.hintTextColor,
                      ),
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.center,
                        child: CustomButton(
                          icon: Icon(
                            Icons.upload,
                            color: colorConstants.hintTextColor,
                          ),
                          height: 44.h,
                          width: 259.w,
                          bordercircular: 10.r,
                          borderColor: colorConstants.hintTextColor,
                          borderWidth: 2.sp,
                          text: "Upload",
                          textColor: colorConstants.hintTextColor,
                          fontSize: 14.sp,
                          fw: FontWeight.w500,
                          onTap: () {
                            addPaymentController.selectOrCaptureImage();
                          },
                        ),
                      ),
                      SizedBox(height: 10.h),
                      CustomText(
                        addPaymentController.walletScreenShot == null
                            ? ""
                            : path.basename(
                                addPaymentController.walletScreenShot!.path,
                              ),
                        color: colorConstants.blackColor,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: CustomButton(
                  height: 44.h,
                  width: 200.w,
                  bordercircular: 8.r,
                  borderColor: Colors.transparent,
                  textColor: colorConstants.primaryColor,
                  borderWidth: 2.sp,
                  text: "Submit",
                  fontSize: 14.sp,
                  fw: FontWeight.w500,
                  boxColor: colorConstants.secondaryColor,
                  onTap: addPaymentController.isPaymentSubmitLoading
                      ? null
                      : () {
                          addPaymentController.addPaymentMethod();
                        },
                  loader: addPaymentController.isPaymentSubmitLoading,
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
                      addPaymentController.selectType("Payment Details");
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
