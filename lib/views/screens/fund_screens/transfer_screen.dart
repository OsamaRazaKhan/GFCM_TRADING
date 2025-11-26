import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:gfcm_trading/views/custom_widgets/searchable_custom_dropdown_button.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  ColorConstants colorConstants = ColorConstants();
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    // Register the controller
    final controller = Get.put(TransferController());

    // Run after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateSelectedTabValue("Transfer");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
      init: TransferController(),
      builder: (transferController) {
        return Form(
          key: formKey,
          child: Container(
            padding: EdgeInsets.all(15.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                  CustomText(
                    "Transfer",
                    size: 20.sp,
                    fw: FontWeight.w500,
                    color: colorConstants.blackColor,
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
                        "Transferring From",
                        size: 16.sp,
                        fw: FontWeight.w400,
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  SearchAbleCustomDropDownButton(
                    selectedValue: transferController.transferFrom,
                    dropDownButtonList: transferController.fromList,
                    text: '',
                    textColor: colorConstants.hintTextColor,
                    textSize: 16.sp,
                    textFw: FontWeight.w400,
                    controller: transferController,
                    valueType: "From",
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
                      CustomText("Amount", size: 16.sp, fw: FontWeight.w400),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  CustomTextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,100}$'),
                      ),
                    ],
                    borderColor: colorConstants.fieldBorderColor,
                    fillColor: colorConstants.fieldColor,
                    validateFunction: transferController.amountValidate,
                    controller: transferController.amountController,
                    onChanged: (value) {
                      transferController.updateFunction();
                    },
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
                        "Transferring To",
                        size: 16.sp,
                        fw: FontWeight.w400,
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  SearchAbleCustomDropDownButton(
                    selectedValue: transferController.transferTo,
                    dropDownButtonList: transferController.toList,
                    text: '',
                    textColor: colorConstants.hintTextColor,
                    textSize: 16.sp,
                    textFw: FontWeight.w400,
                    controller: transferController,
                    valueType: "To",
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      CustomText(
                        "Fee: ",
                        size: 16.sp,
                        fw: FontWeight.w400,
                        color: colorConstants.blackColor,
                      ),
                      SizedBox(width: 10.w),
                      Row(
                        children: [
                          CustomText(
                            transferController.amountFee,
                            size: 14.sp,
                            fw: FontWeight.w700,
                            color: colorConstants.blackColor,
                          ),
                          CustomText(
                            " USD",
                            size: 12.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.hintTextColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      CustomText(
                        "Amount To Be Transferred: ",
                        size: 16.sp,
                        fw: FontWeight.w400,
                        color: colorConstants.blackColor,
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: CustomText(
                                transferController.amountController.text,
                                size: 14.sp,
                                fw: FontWeight.w700,
                                color: colorConstants.blackColor,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: CustomText(
                                " USD",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.center,
                    child: CustomButton(
                      height: 44.h,
                      width: 200.w,
                      bordercircular: 10.r,
                      borderColor: Colors.transparent,
                      borderWidth: 2.sp,
                      text: "Transfer",
                      textColor: colorConstants.primaryColor,
                      fontSize: 14.sp,
                      fw: FontWeight.w500,
                      boxColor: colorConstants.secondaryColor,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          transferController.isTransfer
                              ? null
                              : transferController.transferAmount();
                        }
                      },
                      loader: transferController.isTransfer,
                    ),
                  ),
                ],
              ),
            ),
          );
      },
    );
  }
}
