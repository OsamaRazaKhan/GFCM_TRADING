import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/auth_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  String? id;
  ResetPasswordScreen({super.key, this.id});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
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
          "Reset Password",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),
      backgroundColor: colorConstants.primaryColor,
      body: GetBuilder<AuthController>(
        init: AuthController(),
        builder: (authController) {
          return Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.all(20.r),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50.h),
                    Align(
                      alignment: Alignment.center,
                      child: CustomText(
                        "Enter New Password",
                        color: colorConstants.blackColor,
                        fw: FontWeight.w500,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    CustomTextFormField(
                      borderColor: colorConstants.fieldBorderColor,
                      hintText: "New Password",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: colorConstants.hintTextColor,
                      ),
                      fillColor: colorConstants.fieldColor,
                      validateFunction: authController.newPasswordValidate,
                      controller: authController.newPasswordController,
                    ),
                    SizedBox(height: 20.h),
                    CustomTextFormField(
                      borderColor: colorConstants.fieldBorderColor,
                      hintText: "Confirm Password",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: colorConstants.hintTextColor,
                      ),
                      fillColor: colorConstants.fieldColor,
                      validateFunction: authController.confirmPasswordValidate,
                      controller: authController.confirmPasswordController,
                    ),
                    SizedBox(height: 30.h),
                    Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                        height: 44.h,
                        width: 280.w,
                        bordercircular: 10.r,
                        borderColor: Colors.transparent,
                        borderWidth: 2.sp,
                        text: "Continue",
                        textColor: colorConstants.primaryColor,
                        fontSize: 14.sp,
                        fw: FontWeight.w500,
                        boxColor: colorConstants.secondaryColor,
                        onTap:
                            authController.isResetLoading
                                ? null
                                : () {
                                  if (formKey.currentState!.validate()) {
                                    authController.resetPassword(
                                      context,
                                      widget.id,
                                    );
                                  }
                                },
                        loader: authController.isResetLoading,
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
  }
}
