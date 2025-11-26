import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/data_constants.dart';
import 'package:gfcm_trading/controllers/add_payment_controller.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:gfcm_trading/views/custom_widgets/searchable_custom_dropdown_button.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  AddPaymentController addPaymentController = Get.put(AddPaymentController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addPaymentController.getPaymentTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddPaymentController>(
      init: AddPaymentController(),
      builder: (addPaymentController) {
        return Form(
          key: formKey,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: addPaymentController.selectedPaymentMethod == "Flat"
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                "Payment Details",
                                size: 18.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.blackColor,
                              ),
                              SizedBox(height: 5.h),
                              CustomText(
                                "Please enter payment details below",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                              ),
                              SizedBox(height: 20.h),
                              addPaymentController.isTypeLoading
                                  ? Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorConstants.secondaryColor,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Row(
                                          children: [
                                            CustomText(
                                              "* ",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                              color: colorConstants.redColor,
                                            ),
                                            CustomText(
                                              "Type",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        SearchAbleCustomDropDownButton(
                                          selectedValue: addPaymentController
                                              .selectedPaymentType,
                                          dropDownButtonList:
                                              DataConstants.paymentTypeList,
                                          text: '',
                                          textColor:
                                              colorConstants.hintTextColor,
                                          textSize: 16.sp,
                                          textFw: FontWeight.w400,
                                          controller: addPaymentController,
                                          valueType: "Type",
                                          buttonColor:
                                              colorConstants.primaryColor,
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          children: [
                                            CustomText(
                                              "* ",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                              color: colorConstants.redColor,
                                            ),
                                            CustomText(
                                              "Bank Name",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        CustomTextFormField(
                                          borderColor:
                                              colorConstants.fieldBorderColor,
                                          fillColor:
                                              colorConstants.primaryColor,
                                          validateFunction: addPaymentController
                                              .bankNameValidate,
                                          controller: addPaymentController
                                              .bankNameController,
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          children: [
                                            CustomText(
                                              "* ",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                              color: colorConstants.redColor,
                                            ),
                                            CustomText(
                                              "Account Name",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        CustomTextFormField(
                                          borderColor:
                                              colorConstants.fieldBorderColor,
                                          fillColor:
                                              colorConstants.primaryColor,
                                          validateFunction: addPaymentController
                                              .accountNameValidate,
                                          controller: addPaymentController
                                              .accountNameController,
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          children: [
                                            CustomText(
                                              "* ",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                              color: colorConstants.redColor,
                                            ),
                                            CustomText(
                                              "Account Number",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        CustomTextFormField(
                                          borderColor:
                                              colorConstants.fieldBorderColor,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          fillColor:
                                              colorConstants.primaryColor,
                                          validateFunction: addPaymentController
                                              .accountNumberValidate,
                                          controller: addPaymentController
                                              .accountNumberController,
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          children: [
                                            CustomText(
                                              "* ",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                              color: colorConstants.redColor,
                                            ),
                                            CustomText(
                                              "Swift Code",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        CustomTextFormField(
                                          borderColor:
                                              colorConstants.fieldBorderColor,
                                          fillColor:
                                              colorConstants.primaryColor,
                                          validateFunction: addPaymentController
                                              .swiftNameValidate,
                                          controller: addPaymentController
                                              .swiftNumberController,
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          children: [
                                            CustomText(
                                              "* ",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                              color: colorConstants.redColor,
                                            ),
                                            CustomText(
                                              "Address",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        CustomTextFormField(
                                          borderColor:
                                              colorConstants.fieldBorderColor,
                                          fillColor:
                                              colorConstants.primaryColor,
                                          validateFunction: addPaymentController
                                              .addressValidate,
                                          controller: addPaymentController
                                              .addressController,
                                        ),
                                        SizedBox(height: 20.h),
                                      ],
                                    ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                "Payment Details",
                                size: 18.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.blackColor,
                              ),
                              SizedBox(height: 5.h),
                              CustomText(
                                "Please enter payment details below",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                              ),
                              SizedBox(height: 20.h),
                              addPaymentController.isTypeLoading
                                  ? Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorConstants.secondaryColor,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Row(
                                          children: [
                                            CustomText(
                                              "* ",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                              color: colorConstants.redColor,
                                            ),
                                            CustomText(
                                              "Type",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        SearchAbleCustomDropDownButton(
                                          selectedValue: addPaymentController
                                              .selectedPaymentType,
                                          dropDownButtonList:
                                              addPaymentController
                                                  .paymentTypesList,
                                          text: '',
                                          textColor:
                                              colorConstants.hintTextColor,
                                          textSize: 16.sp,
                                          textFw: FontWeight.w400,
                                          controller: addPaymentController,
                                          valueType: "Type",
                                          buttonColor:
                                              colorConstants.primaryColor,
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          children: [
                                            CustomText(
                                              "* ",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                              color: colorConstants.redColor,
                                            ),
                                            CustomText(
                                              "Address",
                                              size: 16.sp,
                                              fw: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        CustomTextFormField(
                                          borderColor:
                                              colorConstants.fieldBorderColor,
                                          fillColor:
                                              colorConstants.primaryColor,
                                          validateFunction: addPaymentController
                                              .addressValidate,
                                          controller: addPaymentController
                                              .addressController,
                                        ),
                                      ],
                                    ),
                            ],
                          ),
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
                      if (formKey.currentState!.validate()) {
                        if (addPaymentController.selectedPaymentType == null) {
                          FlushMessages.commonToast(
                            "Please select a payment type",
                            backGroundColor: colorConstants.dimGrayColor,
                          );
                        } else {
                          addPaymentController.selectType("Verify");
                        }
                      }
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
          ),
        );
      },
    );
  }
}
