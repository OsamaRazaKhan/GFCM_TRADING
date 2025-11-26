import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/changepayment_dialog_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_quit_dialog.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/screens/add_payments_screens/add_payment_main_dialog.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  ColorConstants colorConstants = ColorConstants();
  @override
  void initState() {
    super.initState();
    // Register the controller
    final transferController = Get.put(TransferController());

    // Run after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transferController.updateSelectedTabValue("Payment");
      transferController.getYourPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
      builder: (transferController) {
        return Container(
          padding: EdgeInsets.all(15.r),
          child: 
                // transferController.isGetPaymentMethods
                //     ? Padding(
                //         padding: EdgeInsets.all(16.0),
                //         child: Center(
                //           child: CircularProgressIndicator(
                //             strokeWidth: 2,
                //             color: colorConstants.secondaryColor,
                //           ),
                //         ),
                //       )
                //     : 
                transferController.isGetPaymentSuccess
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            "Payment Methods",
                            size: 20.sp,
                            fw: FontWeight.w500,
                            color: colorConstants.blackColor,
                          ),
                          SizedBox(height: 15.h),
                          ListView.builder(
                            scrollDirection:
                                Axis.vertical, // or horizontal, doesn’t matter
                            physics:
                                const NeverScrollableScrollPhysics(), //  disables scrolling
                            shrinkWrap:
                                true, //  important if inside another scrollable widget
                            itemCount: transferController
                                .activePaymentMethodsList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.all(15.r),
                                margin: EdgeInsets.only(bottom: 10.h),
                                decoration: BoxDecoration(
                                  color: colorConstants.primaryColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 15.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText(
                                            transferController
                                                .activePaymentMethodsList[index]
                                                .status,
                                            size: 12.sp,
                                            fw: FontWeight.w400,
                                            color: colorConstants.greenColor,
                                          ),
                                          Visibility(
                                            visible: transferController
                                                    .activePaymentMethodsList[
                                                        index]
                                                    .status !=
                                                "inactive",
                                            child: InkWell(
                                              onTap: () {
                                                ChangepaymentDialogWidget
                                                    .paymentDialog(
                                                  userId: transferController
                                                      .activePaymentMethodsList[
                                                          index]
                                                      .userid
                                                      .toString(),
                                                  id: transferController
                                                      .activePaymentMethodsList[
                                                          index]
                                                      .id
                                                      .toString(),
                                                  context,
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(5.r),
                                                child: CustomText(
                                                  "Change",
                                                  size: 12.sp,
                                                  fw: FontWeight.w400,
                                                  color:
                                                      colorConstants.blueColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Transform.scale(
                                                scale: 1.5,
                                                child: Helper.svgIcon(
                                                  transferController
                                                              .activePaymentMethodsList[
                                                                  index]
                                                              .paymenttype ==
                                                          "Crypto"
                                                      ? IconConstants.crypto
                                                      : IconConstants.bankSvg,
                                                  isSelected: false,
                                                  isOriginalColor: true,
                                                  originalColor: colorConstants
                                                      .secondaryColor,
                                                  height: 30,
                                                  width: 30,
                                                ),
                                              ),
                                              SizedBox(width: 20.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      transferController
                                                          .activePaymentMethodsList[
                                                              index]
                                                          .paymenttype,
                                                      size: 16.sp,
                                                      fw: FontWeight.w400,
                                                      color: colorConstants
                                                          .blackColor,
                                                    ),
                                                    CustomText(
                                                      transferController
                                                          .activePaymentMethodsList[
                                                              index]
                                                          .setType,
                                                      size: 12.sp,
                                                      fw: FontWeight.w500,
                                                      color: colorConstants
                                                          .hintTextColor,
                                                    ),
                                                    SizedBox(height: 5.h),
                                                    Visibility(
                                                      visible: transferController
                                                                  .activePaymentMethodsList[
                                                                      index]
                                                                  .status !=
                                                              "readyforactivation" &&
                                                          transferController
                                                                  .activePaymentMethodsList[
                                                                      index]
                                                                  .paymenttype ==
                                                              "Crypto",
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: "Address: ",
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: colorConstants
                                                                    .blackColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "${transferController.activePaymentMethodsList[index].setAddress}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400, // slightly bolder for the name
                                                                  color: colorConstants
                                                                      .dimGrayColor // different color for contrast
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: transferController
                                                                  .activePaymentMethodsList[
                                                                      index]
                                                                  .status !=
                                                              "readyforactivation" &&
                                                          transferController
                                                                  .activePaymentMethodsList[
                                                                      index]
                                                                  .paymenttype ==
                                                              "Flat",
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Name: ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: colorConstants
                                                                        .blackColor,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      "${transferController.activePaymentMethodsList[index].bankname}",
                                                                  style: TextStyle(
                                                                      fontSize: 12.sp,
                                                                      fontWeight: FontWeight.w400, // slightly bolder for the name
                                                                      color: colorConstants.dimGrayColor // different color for contrast
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Account NO: ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: colorConstants
                                                                        .blackColor,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      "${transferController.activePaymentMethodsList[index].accountno}",
                                                                  style: TextStyle(
                                                                      fontSize: 12.sp,
                                                                      fontWeight: FontWeight.w400, // slightly bolder for the name
                                                                      color: colorConstants.dimGrayColor // different color for contrast
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Swift: ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: colorConstants
                                                                        .blackColor,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      "${transferController.activePaymentMethodsList[index].swiftno}",
                                                                  style: TextStyle(
                                                                      fontSize: 12.sp,
                                                                      fontWeight: FontWeight.w400, // slightly bolder for the name
                                                                      color: colorConstants.dimGrayColor // different color for contrast
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Address: ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: colorConstants
                                                                        .blackColor,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      "${transferController.activePaymentMethodsList[index].setAddress}",
                                                                  style: TextStyle(
                                                                      fontSize: 12.sp,
                                                                      fontWeight: FontWeight.w400, // slightly bolder for the name
                                                                      color: colorConstants.dimGrayColor // different color for contrast
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.h),
                                                    Visibility(
                                                      visible: transferController
                                                              .activePaymentMethodsList[
                                                                  index]
                                                              .status ==
                                                          "readyforactivation",
                                                      child: CustomText(
                                                        "Your account is ready for activation. Tap 'Change' to activate",
                                                        size: 12.sp,
                                                        fw: FontWeight.w500,
                                                        color: colorConstants
                                                            .hintTextColor,
                                                        maxLines:
                                                            null, // allow wrapping
                                                        textOverflow:
                                                            TextOverflow
                                                                .visible,
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            CustomDialogs.showQuitDialog(
                                              context,
                                              width: 358.w,
                                              height: 300.h,
                                              radius: 10.r,
                                              buttonHeight: 44.h,
                                              isDeleteLoading:
                                                  transferController
                                                      .isDeleteLoading,
                                              headText:
                                                  "Confirm Account Removal",
                                              messageText:
                                                  "Are you sure you want to delete this payment method? This account will be permanently removed from your profile.",
                                              quitText: "Remove",
                                              cancelText: "Cancel",
                                              onTap: () async {
                                                transferController
                                                    .deletePaymentMethod(
                                                  transferController
                                                      .activePaymentMethodsList[
                                                          index]
                                                      .id
                                                      .toString(),
                                                  transferController
                                                      .activePaymentMethodsList[
                                                          index]
                                                      .userid
                                                      .toString(),
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(
                                            Icons.delete_outline_outlined,
                                            color: colorConstants.redColor,
                                            size: 30.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              String? type;
                              if (transferController
                                  .activePaymentMethodsList.isNotEmpty) {
                                type = transferController
                                    .activePaymentMethodsList[0].paymenttype!;
                              }
                              AddPaymentMainDialog.addPaymentDialog(
                                methodsIsEmpty: transferController
                                    .activePaymentMethodsList.isEmpty,
                                context,
                                type: type,
                              );
                            },
                            child: Container(
                              width: 356.w,
                              padding: EdgeInsets.only(
                                left: 5.w,
                                right: 15.w,
                                top: 15.h,
                                bottom: 15.h,
                              ),
                              decoration: BoxDecoration(
                                color: colorConstants.primaryColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 52.h,
                                    width: 52.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorConstants.bottomDarkGrayCol,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 35.sp,
                                      color: colorConstants.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          "Add Payment Method",
                                          size: 16.sp,
                                          fw: FontWeight.w400,
                                          color: colorConstants.blackColor,
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: CustomText(
                                                "Add Payment Method for withdrawal",
                                                size: 12.sp,
                                                fw: FontWeight.w500,
                                                color: colorConstants
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
                          ),
                        ],
                      )
                    : CustomEmptyScreenMessage(
                        icon: Icon(
                          Icons.cloud_off,
                          size: 80.sp,
                          color: colorConstants.hintTextColor,
                        ),
                        headText: "Unable to Load Payment Method",
                        subtext:
                            "There was an issue retrieving your payment method. Please refresh or try again shortly.",
                        onTap: () {
                          transferController.getYourPaymentMethods();
                        },
                      ),
        );
      },
    );
  }
}
