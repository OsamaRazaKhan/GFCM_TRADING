import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/data_constants.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';
import 'package:gfcm_trading/controllers/withdraw_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:gfcm_trading/views/custom_widgets/searchable_custom_dropdown_button.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    // Register the controller
    final controller = Get.put(TransferController());

    // Run after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateSelectedTabValue("Withdraw");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawController>(
      init: WithdrawController(),
      builder: (withdrawController) {
        return Form(
          key: formKey,
          child: Container(
            padding: EdgeInsets.all(15.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  "Withdrawal funds",
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
                    CustomText("Wallet", size: 16.sp, fw: FontWeight.w400),
                  ],
                ),
                SizedBox(height: 5.h),
                SearchAbleCustomDropDownButton(
                  selectedValue: withdrawController.selectedWallet,
                  dropDownButtonList: DataConstants.withDrawAccountsList,
                  text: 'Select',
                  textColor: colorConstants.hintTextColor,
                  textSize: 12.sp,
                  textFw: FontWeight.w400,
                  controller: withdrawController,
                  valueType: "Wallet",
                ),

                SizedBox(height: 10.h),

                Column(
                  children: [
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
                    CustomTextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,100}$'),
                        ),
                      ],
                      borderColor: colorConstants.fieldBorderColor,

                      fillColor: colorConstants.fieldColor,
                      validateFunction: withdrawController.feeValidate,
                      controller: withdrawController.amountController,
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
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
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        withdrawController.isWithDraw
                            ? null
                            : withdrawController.withDrawAmount();
                      }
                    },
                    loader: withdrawController.isWithDraw,
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
