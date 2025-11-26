// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/models/gfcm_payment_model.dart';
import 'package:path/path.dart' as path;
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/deposit_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';

class DepositDilogWidget {
  static void depositDialog(
    BuildContext context, {
    double? height,
    double? width,
    String? userId,
    String? password,
    String? server,
  }) {
    GlobalKey<FormState> formKey = GlobalKey();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: colorConstants.primaryColor,
          child: GetBuilder<DepositController>(
            init: DepositController(),
            builder: (depositController) {
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
                              //Based on the account type show bank/crypto
                              "Funds With USD ",
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
                          hintText: "Amount",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            color: colorConstants.hintTextColor,
                          ),
                          fillColor: colorConstants.fieldColor,
                          validateFunction: depositController.amountValidate,
                          controller: depositController.amountController,
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
                            text: "Next",
                            textColor: colorConstants.primaryColor,
                            fontSize: 14.sp,
                            fw: FontWeight.w500,
                            boxColor: colorConstants.secondaryColor,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                depositSubmitDialog(context);
                              }
                            },
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

  static void depositSubmitDialog(
    BuildContext context, {
    double? height,
    double? width,
    String? userId,
    String? password,
    String? server,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: colorConstants.primaryColor,
          child: GetBuilder<DepositController>(
            init: DepositController(),
            builder: (depositController) {
              return Container(
                clipBehavior: Clip.none,
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                width: 358.w,
                height: 700.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GetBuilder<TransferController>(
                        builder: (transferController) {
                          // Get the selected payment method type from the stored specific method
                          String paymentTypeText = "Tether";
                          if (transferController.selectedGfcmPaymentMethod != null) {
                            // Use the stored specific method
                            final methodType = (transferController.selectedGfcmPaymentMethod!.paymenttype ?? "Tether").toLowerCase();
                            paymentTypeText = methodType.isEmpty 
                                ? "Tether"
                                : methodType[0].toUpperCase() + methodType.substring(1);
                          } else if (transferController.gfcmPaymentMethod.isNotEmpty) {
                            // Fallback: use first method if no specific method is stored
                            final firstMethod = transferController.gfcmPaymentMethod[0];
                            final methodType = (firstMethod.paymenttype ?? "Tether").toLowerCase();
                            paymentTypeText = methodType.isEmpty 
                                ? "Tether"
                                : methodType[0].toUpperCase() + methodType.substring(1);
                          }
                          
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                "Funds With $paymentTypeText",
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
                          );
                        },
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Fee",
                            size: 16.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.hintTextColor,
                          ),
                          Row(
                            children: [
                              CustomText(
                                "00",
                                size: 16.sp,
                                fw: FontWeight.w500,
                                color: colorConstants.blackColor,
                              ),
                              SizedBox(width: 3.w),
                              CustomText(
                                "USD",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Amount To Receive",
                            size: 16.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.hintTextColor,
                          ),
                          Row(
                            children: [
                              CustomText(
                                depositController.amountController.text,
                                size: 16.sp,
                                fw: FontWeight.w500,
                                color: colorConstants.blackColor,
                              ),
                              SizedBox(width: 3.w),
                              CustomText(
                                "USD",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            "Amount To Send",
                            size: 16.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.hintTextColor,
                          ),
                          Row(
                            children: [
                              CustomText(
                                depositController.amountController.text,
                                size: 16.sp,
                                fw: FontWeight.w500,
                                color: colorConstants.blackColor,
                              ),
                              SizedBox(width: 3.w),
                              CustomText(
                                "USD",
                                size: 12.sp,
                                fw: FontWeight.w400,
                                color: colorConstants.hintTextColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Transform.scale(
                              scale: 2.0,
                              child: Helper.svgIcon(
                                IconConstants.qrScanner,
                                isSelected: false,
                                isOriginalColor: true,
                                originalColor: colorConstants.blackColor,
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomText(
                                  "Copy Account Details",
                                  // "COPY ACCOUNT DETAILS",
                                  size: 14.sp,
                                  fw: FontWeight.w500,
                                  color: colorConstants.blackColor,
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10.h),
                                CustomButton(
                                  icon: Icon(
                                    Icons.copy_all_rounded,
                                    color: colorConstants.primaryColor,
                                  ),
                                  height: 33.h,
                                  width: 97.w,
                                  bordercircular: 10.r,
                                  borderColor: Colors.transparent,
                                  borderWidth: 2.sp,
                                  text: "Copy",
                                  textColor: colorConstants.primaryColor,
                                  fontSize: 14.sp,
                                  fw: FontWeight.w500,
                                  boxColor: colorConstants.secondaryColor,
                                  onTap: () {
                                    // Resolve what to copy based on selected payment type
                                    TransferController transferController;
                                    if (!Get.isRegistered<
                                        TransferController>()) {
                                      transferController =
                                          Get.put(TransferController());
                                    } else {
                                      transferController =
                                          Get.find<TransferController>();
                                    }

                                    // Use the stored specific payment method
                                    final method = transferController.selectedGfcmPaymentMethod;
                                    
                                    if (method == null) {
                                      // Fallback: if no specific method stored, use first available
                                      if (transferController.gfcmPaymentMethod.isEmpty) {
                                        return;
                                      }
                                      final fallbackMethod = transferController.gfcmPaymentMethod[0];
                                      final isBank = (fallbackMethod.paymenttype?.toLowerCase() ?? "") == "bank";
                                      
                                      String valueToCopy = "";
                                      String copiedWhat = "";
                                      
                                      if (isBank) {
                                        valueToCopy = (fallbackMethod.accountno ?? "").trim();
                                        copiedWhat = "Account No";
                                      } else {
                                        valueToCopy = (fallbackMethod.setAddress ?? "").trim();
                                        if (valueToCopy.isEmpty) {
                                          valueToCopy = (fallbackMethod.accountno ?? "").trim();
                                          copiedWhat = "Account No";
                                        } else {
                                          copiedWhat = "Address";
                                        }
                                      }
                                      
                                      if (valueToCopy.isNotEmpty) {
                                        Clipboard.setData(ClipboardData(text: valueToCopy));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: CustomText(
                                              "$copiedWhat copied",
                                              color: colorConstants.primaryColor,
                                            ),
                                            backgroundColor: colorConstants.secondaryColor,
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    String valueToCopy = "";
                                    String copiedWhat = "";

                                    final isBank = (method.paymenttype?.toLowerCase() ?? "") == "bank";
                                    
                                    if (isBank) {
                                      // For bank, copy account number
                                      valueToCopy = (method.accountno ?? "").trim();
                                      copiedWhat = "Account No";
                                    } else {
                                      // For crypto, copy address (with fallback to account number)
                                      valueToCopy = (method.setAddress ?? "").trim();
                                      if (valueToCopy.isEmpty) {
                                        valueToCopy = (method.accountno ?? "").trim();
                                        copiedWhat = "Account No";
                                      } else {
                                        copiedWhat = "Address";
                                      }
                                    }

                                    if (valueToCopy.isNotEmpty) {
                                      Clipboard.setData(
                                          ClipboardData(text: valueToCopy));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: CustomText(
                                            "$copiedWhat copied",
                                            color: colorConstants.primaryColor,
                                          ),
                                          backgroundColor:
                                              colorConstants.secondaryColor,
                                        ),
                                      );
                                    }
                                  },
                                  // onTap: () {
                                  //   // Resolve what to copy based on selected payment type
                                  //   TransferController transferController;
                                  //   if (!Get.isRegistered<
                                  //       TransferController>()) {
                                  //     transferController =
                                  //         Get.put(TransferController());
                                  //   } else {
                                  //     transferController =
                                  //         Get.find<TransferController>();
                                  //   }

                                  //   final method = transferController
                                  //           .gfcmPaymentMethod.isNotEmpty
                                  //       ? transferController
                                  //           .gfcmPaymentMethod[0]
                                  //       : null;
                                  //   final selected = transferController
                                  //           .selectedDepositMethod
                                  //           ?.toLowerCase() ??
                                  //       "";

                                  //   String valueToCopy = "";
                                  //   String copiedWhat = "Details";
                                  //   if (method != null) {
                                  //     if (selected == "bank") {
                                  //       valueToCopy =
                                  //           (method.accountno ?? "").trim();
                                  //       copiedWhat = "Account No";
                                  //     } else if (selected == "crypto") {
                                  //       // Prefer address for crypto; fallback to account number if provided
                                  //       valueToCopy =
                                  //           (method.setAddress ?? "").trim();
                                  //       if (valueToCopy.isEmpty) {
                                  //         valueToCopy =
                                  //             (method.accountno ?? "").trim();
                                  //         copiedWhat = "Account No";
                                  //       } else {
                                  //         copiedWhat = "Address";
                                  //       }
                                  //     } else {
                                  //       // Fallback when not selected: do nothing
                                  //       valueToCopy = "";
                                  //     }
                                  //   }

                                  //   if (valueToCopy.isNotEmpty) {
                                  //     Clipboard.setData(
                                  //         ClipboardData(text: valueToCopy));
                                  //     ScaffoldMessenger.of(context)
                                  //         .showSnackBar(
                                  //       SnackBar(
                                  //         content: CustomText(
                                  //           "$copiedWhat copied",
                                  //           color: colorConstants.primaryColor,
                                  //         ),
                                  //         backgroundColor:
                                  //             colorConstants.secondaryColor,
                                  //       ),
                                  //     );
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Bank details section - same as deposit method screen
                      CustomText(
                        "Account Details",
                        size: 17.sp,
                        fw: FontWeight.w500,
                        color: colorConstants.blackColor,
                      ),
                      SizedBox(height: 10.h),
                      GetBuilder<TransferController>(
                        builder: (transferController) {
                          // Use the stored specific payment method
                          GfcmPaymentModel? method = transferController.selectedGfcmPaymentMethod;
                          
                          // Fallback: if no specific method stored, use first available
                          if (method == null) {
                            if (transferController.gfcmPaymentMethod.isEmpty) {
                              return SizedBox.shrink();
                            }
                            method = transferController.gfcmPaymentMethod[0];
                          }
                          
                          final selected = method.paymenttype?.toLowerCase() ?? "";
                          final isBank = selected == "bank";

                          return Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              color: colorConstants.bottomDarkGrayCol,
                            ),
                            child: Column(
                              children: [
                                if (isBank) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Name",
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        (method.accountname ?? "")
                                                .trim()
                                                .isEmpty
                                            ? "-"
                                            : method.accountname!,
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Account No",
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        (method.accountno ?? "").trim().isEmpty
                                            ? "-"
                                            : method.accountno!,
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Swift",
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        ((method.swiftno ?? "").trim().isEmpty)
                                            ? "-"
                                            : method.swiftno!.trim(),
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Bank",
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        (method.bankname ?? "").trim().isEmpty
                                            ? "-"
                                            : method.bankname!,
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Address",
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                      CustomText(
                                        (method.setAddress ?? "").trim().isEmpty
                                            ? "-"
                                            : method.setAddress!,
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  if (method.setType != null && method.setType!.trim().isNotEmpty) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          "Type",
                                          size: 12.sp,
                                          fw: FontWeight.w400,
                                          color: colorConstants.blackColor,
                                        ),
                                        CustomText(
                                          method.setType!,
                                          size: 12.sp,
                                          fw: FontWeight.w400,
                                          color: colorConstants.blackColor,
                                        ),
                                      ],
                                    ),
                                    Divider(thickness: 1),
                                  ],
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Address",
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.blackColor,
                                      ),
                                      Expanded(
                                        child: CustomText(
                                          (method.setAddress ?? "").trim().isEmpty
                                              ? "-"
                                              : method.setAddress!,
                                          size: 12.sp,
                                          fw: FontWeight.w400,
                                          color: colorConstants.blackColor,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (method.accountname != null && method.accountname!.trim().isNotEmpty) ...[
                                    Divider(thickness: 1),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          "Name",
                                          size: 12.sp,
                                          fw: FontWeight.w400,
                                          color: colorConstants.blackColor,
                                        ),
                                        CustomText(
                                          method.accountname!,
                                          size: 12.sp,
                                          fw: FontWeight.w400,
                                          color: colorConstants.blackColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (method.accountno != null && method.accountno!.trim().isNotEmpty) ...[
                                    Divider(thickness: 1),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          "Account No",
                                          size: 12.sp,
                                          fw: FontWeight.w400,
                                          color: colorConstants.blackColor,
                                        ),
                                        CustomText(
                                          method.accountno!,
                                          size: 12.sp,
                                          fw: FontWeight.w400,
                                          color: colorConstants.blackColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(
                        icon: Icon(
                          Icons.download,
                          color: colorConstants.primaryColor,
                        ),
                        height: 38.h,
                        width: 143.w,
                        bordercircular: 10.r,
                        borderColor: Colors.transparent,
                        borderWidth: 2.sp,
                        text: "Select File",
                        textColor: colorConstants.primaryColor,
                        fontSize: 14.sp,
                        fw: FontWeight.w400,
                        boxColor: colorConstants.secondaryColor,
                        onTap: () {
                          depositController.selectOrCaptureImage();
                        },
                      ),
                      SizedBox(height: 10.h),
                      CustomText(
                        depositController.depositScreenShot == null
                            ? ""
                            : path.basename(
                                depositController.depositScreenShot!.path,
                              ),
                        size: 14.sp,
                        fw: FontWeight.w500,
                        color: colorConstants.blackColor,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 15.h),
                      Align(
                        alignment: Alignment.center,
                        child: CustomButton(
                          height: 38.h,
                          width: 200.w,
                          bordercircular: 10.r,
                          borderColor: Colors.transparent,
                          borderWidth: 2.sp,
                          text: "Submit",
                          textColor: colorConstants.primaryColor,
                          fontSize: 14.sp,
                          fw: FontWeight.w500,
                          boxColor: colorConstants.secondaryColor,
                          onTap: () {
                            depositController.isDeposit
                                ? null
                                : depositController.depositYourAmount();
                          },
                          loader: depositController.isDeposit,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: colorConstants.dimGrayColor,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: CustomText(
                              "Back To Previous",
                              color: colorConstants.dimGrayColor,
                              size: 14.sp,
                              fw: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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
