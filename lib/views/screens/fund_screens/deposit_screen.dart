import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';
import 'package:gfcm_trading/global.dart';
import 'package:gfcm_trading/models/gfcm_payment_model.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/deposit_dilog_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/searchable_custom_dropdown_button.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  ColorConstants colorConstants = ColorConstants();
  @override
  void initState() {
    super.initState();

    // Register the controller
    final transferController = Get.put(TransferController());

    // Run after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transferController.updateSelectedTabValue("Deposit");
      // Set "All" as default payment type
      if (transferController.selectedDepositMethod == null) {
        transferController.selectValueFromSearchAbleDropDown(
            "DepositMethod", "All");
      }
      transferController.getGfcmPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
      builder: (transferController) {
        // if (transferController.isGetGfcmMethod) {
        //   return Padding(
        //     padding: EdgeInsets.all(16.0),
        //     child: Center(
        //       child: CircularProgressIndicator(
        //         strokeWidth: 2,
        //         color: colorConstants.secondaryColor,
        //       ),
        //     ),
        //   );
        // }

        if (transferController.gfcmPaymentMethod.isEmpty) {
          return CustomEmptyScreenMessage(
            icon: Icon(
              Icons.cloud_off,
              size: 80.sp,
              color: colorConstants.hintTextColor,
            ),
            headText: "Unable to Load Deposit Methods",
            subtext:
                "Please refresh the page to try again and view the available deposit option.",
            onTap: () {
              transferController.getGfcmPayment();
            },
          );
        }

        return Padding(
          padding: EdgeInsets.only(top: 230),
          child: ListView(
            shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(), // disable child scroll
            // mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  color: colorConstants.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Select Payment Type",
                      size: 16.sp,
                      fw: FontWeight.w500,
                      color: colorConstants.blackColor,
                    ),
                    SizedBox(height: 10.h),
                    SearchAbleCustomDropDownButton(
                      selectedValue: transferController.selectedDepositMethod,
                      dropDownButtonList: const ["All", "Bank", "Crypto"],
                      text: 'Select',
                      textColor: colorConstants.hintTextColor,
                      textSize: 12.sp,
                      textFw: FontWeight.w400,
                      controller: transferController,
                      valueType: "DepositMethod",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              // Show deposit methods if payment type is selected (including "All")
              if (transferController.selectedDepositMethod != null &&
                  transferController.selectedDepositMethod!.isNotEmpty) ...[
                CustomText(
                  "Deposit Methods",
                  size: 20.sp,
                  fw: FontWeight.w500,
                  color: colorConstants.blackColor,
                ),
                SizedBox(height: 15.h),
                Builder(
                  builder: (context) {
                    // Filter methods based on selected payment type
                    List<GfcmPaymentModel> filteredMethods = [];
                    final selectedType =
                        transferController.selectedDepositMethod?.toLowerCase();

                    if (selectedType == "all") {
                      // Show all methods
                      filteredMethods = transferController.gfcmPaymentMethod;
                    } else {
                      // Filter by selected type (bank or crypto)
                      filteredMethods = transferController.gfcmPaymentMethod
                          .where((method) =>
                              (method.paymenttype?.toLowerCase() ?? "") ==
                              selectedType)
                          .toList();
                    }

                    if (filteredMethods.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CustomText(
                            "No payment methods found for the selected type",
                            size: 14.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.hintTextColor,
                          ),
                        ),
                      );
                    }

                    // Display all filtered methods
                    return Column(
                      children: filteredMethods.asMap().entries.map((entry) {
                        final index = entry.key;
                        final method = entry.value;
                        return Column(
                          children: [
                            _buildDepositMethodCard(
                              transferController: transferController,
                              colorConstants: colorConstants,
                              context: context,
                              method: method,
                            ),
                            if (index < filteredMethods.length - 1)
                              SizedBox(height: 15.h),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepositMethodCard({
    required TransferController transferController,
    required ColorConstants colorConstants,
    required BuildContext context,
    required GfcmPaymentModel method,
  }) {
    final isBank = (method.paymenttype?.toLowerCase() ?? "") == "bank";

    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colorConstants.primaryColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipOval(
              child: (isBank &&
                      method.banklogo != null &&
                      method.banklogo!.isNotEmpty)
                  ? Image.network(
                      "https://backend.gfcmgroup.com/uploads/${method.banklogo}",
                      height: 50.h,
                      width: 50.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 50.h,
                          width: 50.w,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.account_balance,
                            size: 24.sp,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : (!isBank &&
                          method.setVerification != null &&
                          method.setVerification!.isNotEmpty)
                      ? Image.network(
                          "https://backend.gfcmgroup.com/uploads/${method.setVerification}",
                          height: 50.h,
                          width: 50.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 50.h,
                              width: 50.w,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.account_balance_wallet,
                                size: 24.sp,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 50.h,
                          width: 50.w,
                          color: Colors.grey.shade200,
                          child: Icon(
                            isBank
                                ? Icons.account_balance
                                : Icons.account_balance_wallet,
                            size: 24.sp,
                            color: Colors.grey,
                          ),
                        ),
            ),
            title: CustomText(
              method.paymenttype?.toUpperCase() ?? "",
              size: 14.sp,
              fw: FontWeight.w500,
            ),
            subtitle: CustomText(
              isBank ? (method.bankname ?? "") : (method.setType ?? ""),
              size: 12.sp,
              fw: FontWeight.w400,
              color: colorConstants.hintTextColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Currency",
                      size: 14.sp,
                      fw: FontWeight.w400,
                      textAlign: TextAlign.center,
                      color: colorConstants.hintTextColor,
                    ),
                    SizedBox(height: 10.h),
                    CustomText(
                      "USD",
                      size: 14.sp,
                      fw: FontWeight.w500,
                      textAlign: TextAlign.center,
                      color: colorConstants.blackColor,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Fee",
                      size: 14.sp,
                      fw: FontWeight.w400,
                      textAlign: TextAlign.center,
                      color: colorConstants.hintTextColor,
                    ),
                    SizedBox(height: 10.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "0%+0",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: colorConstants.blackColor,
                            ),
                          ),
                          TextSpan(
                            text: " USD",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: colorConstants.hintTextColor,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Minimum",
                      size: 14.sp,
                      fw: FontWeight.w400,
                      textAlign: TextAlign.center,
                      color: colorConstants.hintTextColor,
                    ),
                    SizedBox(height: 10.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "20",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: colorConstants.blackColor,
                            ),
                          ),
                          TextSpan(
                            text: " USD",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: colorConstants.hintTextColor,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Processing Time",
                      size: 14.sp,
                      fw: FontWeight.w400,
                      textAlign: TextAlign.center,
                      color: colorConstants.hintTextColor,
                    ),
                    SizedBox(height: 10.h),
                    CustomText(
                      "Within 22 Min",
                      size: 16.sp,
                      fw: FontWeight.w500,
                      textAlign: TextAlign.center,
                      color: colorConstants.blackColor,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: colorConstants.bottomDarkGrayCol,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBank) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: CustomText(
                          "Name",
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 2,
                        child: CustomText(
                          (method.accountname ?? "").trim().isEmpty
                              ? "-"
                              : method.accountname!,
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          textOverflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: CustomText(
                          "Account No",
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 2,
                        child: CustomText(
                          (method.accountno ?? "").trim().isEmpty
                              ? "-"
                              : method.accountno!,
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          textOverflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: CustomText(
                          "Swift",
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 2,
                        child: CustomText(
                          ((method.swiftno ?? "").trim().isEmpty)
                              ? "-"
                              : method.swiftno!.trim(),
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          textOverflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: CustomText(
                          "Bank",
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 2,
                        child: CustomText(
                          (method.bankname ?? "").trim().isEmpty
                              ? "-"
                              : method.bankname!,
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          textOverflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: CustomText(
                          "Address",
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 2,
                        child: CustomText(
                          (method.setAddress ?? "").trim().isEmpty
                              ? "-"
                              : method.setAddress!,
                          size: 12.sp,
                          fw: FontWeight.w400,
                          color: colorConstants.blackColor,
                          textAlign: TextAlign.right,
                          maxLines: 5,
                          textOverflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  if (method.setType != null &&
                      method.setType!.trim().isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  if (method.accountname != null &&
                      method.accountname!.trim().isNotEmpty) ...[
                    Divider(thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  if (method.accountno != null &&
                      method.accountno!.trim().isNotEmpty) ...[
                    Divider(thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              text: "Deposit",
              textColor: colorConstants.primaryColor,
              fontSize: 14.sp,
              fw: FontWeight.w500,
              boxColor: colorConstants.secondaryColor,
              onTap: () {
                isBank
                    ? globalBankNameOrType = method.bankname
                    : globalBankNameOrType = method.setType;
                // Set the selected method and specific payment method before opening dialog
                transferController.selectedDepositMethod = method.paymenttype;
                transferController.selectedGfcmPaymentMethod = method;
                transferController.update();
                DepositDilogWidget.depositDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
