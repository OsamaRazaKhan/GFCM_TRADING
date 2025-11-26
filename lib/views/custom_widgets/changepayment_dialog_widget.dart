import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';

import 'package:gfcm_trading/controllers/payment_controller.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class ChangepaymentDialogWidget {
  static void paymentDialog(
    BuildContext context, {
    double? height,
    double? width,
    String? userId,
    String? password,
    String? server,
    String? id,
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
          child: GetBuilder<PaymentController>(
            init: PaymentController(),
            builder: (paymentController) {
              return Form(
                key: formKey,
                child: Container(
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.all(15.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: colorConstants.primaryColor,
                  ),
                  width: 358.w,
                  height: 300.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                        SizedBox(height: 30.h),

                        Align(
                          alignment: Alignment.center,
                          child: CustomText(
                            "Confirm Payment Method Activation",
                            size: 16.sp,
                            fw: FontWeight.w700,
                            color: colorConstants.blackColor,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        Align(
                          alignment: Alignment.center,
                          child: CustomText(
                            "Please confirm if you want to activate this payment method. Select OK to proceed",
                            size: 10.sp,
                            fw: FontWeight.w600,
                            color: colorConstants.blackColor,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        //old Ui here
                        SizedBox(height: 40.h),
                        Align(
                          alignment: Alignment.center,
                          child: CustomButton(
                            height: 44.h,
                            width: 200.w,
                            bordercircular: 8.r,
                            borderColor: Colors.transparent,
                            textColor: colorConstants.primaryColor,
                            borderWidth: 2.sp,
                            text: "Ok",
                            fontSize: 14.sp,
                            fw: FontWeight.w500,
                            boxColor: colorConstants.secondaryColor,
                            onTap: () {
                              paymentController.isPaymentUpdate
                                  ? null
                                  : paymentController.updateYourPaymentMethod(
                                    id ?? "0",
                                    userId ?? "0",
                                  );
                            },
                            loader: paymentController.isPaymentUpdate,
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


 // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     CustomText(
                        //       "Change Payment Method",
                        //       size: 18.sp,
                        //       fw: FontWeight.w500,
                        //       color: colorConstants.blackColor,
                        //     ),
                        //     IconButton(
                        //       onPressed: () {
                        //         Navigator.pop(context);
                        //       },
                        //       icon: Icon(
                        //         Icons.close,
                        //         color: colorConstants.blackColor,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 30.h),

                        // Container(
                        //   width: 356.w,
                        //   padding: EdgeInsets.all(20.r),
                        //   decoration: BoxDecoration(
                        //     color: colorConstants.bottomDarkGrayCol,
                        //     borderRadius: BorderRadius.circular(12.r),
                        //   ),
                        //   child: Column(
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,

                        //         children: [
                        //           Flexible(
                        //             child: Row(
                        //               children: [
                        //                 Transform.scale(
                        //                   scale: 1.5,
                        //                   child: Helper.svgIcon(
                        //                     IconConstants.bankSvg,
                        //                     isSelected: false,
                        //                     isOriginalColor: true,
                        //                     originalColor:
                        //                         colorConstants.secondaryColor,
                        //                     height: 30,
                        //                     width: 30,
                        //                   ),
                        //                 ),
                        //                 SizedBox(width: 20.w),
                        //                 Flexible(
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.start,
                        //                     children: [
                        //                       CustomText(
                        //                         "Flat",
                        //                         size: 16.sp,
                        //                         fw: FontWeight.w500,
                        //                         color:
                        //                             colorConstants.blackColor,
                        //                       ),
                        //                       Row(
                        //                         children: [
                        //                           Flexible(
                        //                             child: CustomText(
                        //                               "Add payment method like banks or credit cards",
                        //                               size: 12.sp,
                        //                               fw: FontWeight.w400,
                        //                               color:
                        //                                   colorConstants
                        //                                       .hintTextColor,
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //           SizedBox(width: 5.w),
                        //           GestureDetector(
                        //             onTap: () {
                        //               paymentController.selectPaymentmethod(
                        //                 "Flat",
                        //               );
                        //             },
                        //             child: Container(
                        //               height: 20.h,
                        //               width: 20.w,
                        //               decoration: BoxDecoration(
                        //                 shape: BoxShape.circle,
                        //                 border: Border.all(
                        //                   width: 2.w,
                        //                   color: colorConstants.primaryColor,
                        //                 ),
                        //                 color:
                        //                     paymentController
                        //                                 .selectedPaymentMethod ==
                        //                             "Flat"
                        //                         ? colorConstants.secondaryColor
                        //                         : colorConstants.primaryColor,
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(height: 15.h),
                        // Container(
                        //   width: 356.w,
                        //   padding: EdgeInsets.all(20.r),
                        //   decoration: BoxDecoration(
                        //     color: colorConstants.bottomDarkGrayCol,
                        //     borderRadius: BorderRadius.circular(12.r),
                        //   ),
                        //   child: Column(
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,

                        //         children: [
                        //           Flexible(
                        //             child: Row(
                        //               children: [
                        //                 Transform.scale(
                        //                   scale: 1.5,
                        //                   child: Helper.svgIcon(
                        //                     IconConstants.crypto,
                        //                     isSelected: false,
                        //                     isOriginalColor: true,
                        //                     originalColor:
                        //                         colorConstants.secondaryColor,
                        //                     height: 30,
                        //                     width: 30,
                        //                   ),
                        //                 ),
                        //                 SizedBox(width: 20.w),
                        //                 Flexible(
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.start,
                        //                     children: [
                        //                       CustomText(
                        //                         "Crypto",
                        //                         size: 16.sp,
                        //                         fw: FontWeight.w500,
                        //                         color:
                        //                             colorConstants.blackColor,
                        //                       ),
                        //                       Row(
                        //                         children: [
                        //                           Flexible(
                        //                             child: CustomText(
                        //                               "Add payment method like banks or credit cards",
                        //                               size: 12.sp,
                        //                               fw: FontWeight.w400,
                        //                               color:
                        //                                   colorConstants
                        //                                       .hintTextColor,
                        //                             ),
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //           SizedBox(width: 5.w),
                        //           GestureDetector(
                        //             onTap: () {
                        //               paymentController.selectPaymentmethod(
                        //                 "Crypto",
                        //               );
                        //             },
                        //             child: Container(
                        //               height: 20.h,
                        //               width: 20.w,
                        //               decoration: BoxDecoration(
                        //                 shape: BoxShape.circle,
                        //                 border: Border.all(
                        //                   width: 2.w,
                        //                   color: colorConstants.primaryColor,
                        //                 ),
                        //                 color:
                        //                     paymentController
                        //                                 .selectedPaymentMethod ==
                        //                             "Crypto"
                        //                         ? colorConstants.secondaryColor
                        //                         : colorConstants.primaryColor,
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(height: 25.h),
                        // Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     CustomText(
                        //       "Front Side OF ID",
                        //       size: 14.sp,
                        //       fw: FontWeight.w500,
                        //       color: colorConstants.hintTextColor,
                        //     ),
                        //     SizedBox(height: 10.h),
                        //     Align(
                        //       alignment: Alignment.center,
                        //       child: CustomButton(
                        //         icon: Icon(
                        //           Icons.upload,
                        //           color: colorConstants.hintTextColor,
                        //         ),
                        //         height: 44.h,
                        //         width: 259.w,
                        //         bordercircular: 10.r,
                        //         borderColor: colorConstants.hintTextColor,

                        //         borderWidth: 2.sp,
                        //         text: "Upload",
                        //         textColor: colorConstants.hintTextColor,
                        //         fontSize: 14.sp,
                        //         fw: FontWeight.w400,

                        //         onTap: () {
                        //           paymentController.selectOrCaptureImage(
                        //             false,
                        //             true,
                        //           );
                        //         },
                        //       ),
                        //     ),
                        //     SizedBox(height: 20.h),
                        //     CustomText(
                        //       "Back Side OF ID",
                        //       size: 14.sp,
                        //       fw: FontWeight.w500,
                        //       color: colorConstants.hintTextColor,
                        //     ),
                        //     SizedBox(height: 10.h),
                        //     Align(
                        //       alignment: Alignment.center,
                        //       child: CustomButton(
                        //         icon: Icon(
                        //           Icons.upload,
                        //           color: colorConstants.hintTextColor,
                        //         ),
                        //         height: 44.h,
                        //         width: 259.w,
                        //         bordercircular: 10.r,
                        //         borderColor: colorConstants.hintTextColor,

                        //         borderWidth: 2.sp,
                        //         text: "Upload",
                        //         textColor: colorConstants.hintTextColor,
                        //         fontSize: 14.sp,
                        //         fw: FontWeight.w400,

                        //         onTap: () {
                        //           paymentController.selectOrCaptureImage(
                        //             false,
                        //             false,
                        //           );
                        //         },
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 30.h),

                        // Row(
                        //   children: [
                        //     CustomText(
                        //       "* ",
                        //       size: 16.sp,
                        //       fw: FontWeight.w400,
                        //       color: colorConstants.redColor,
                        //     ),
                        //     CustomText(
                        //       "CNIC Number",
                        //       size: 14.sp,
                        //       fw: FontWeight.w400,
                        //     ),
                        //   ],
                        // ),

                        // SizedBox(height: 5.h),
                        // CustomTextFormField(
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //   ],
                        //   borderColor: colorConstants.fieldBorderColor,

                        //   fillColor: colorConstants.primaryColor,
                        //   validateFunction: paymentController.cnicValidate,
                        //   controller: paymentController.cnicController,
                        // ),
                        // SizedBox(height: 15.h),
                        // GestureDetector(
                        //   onTap: () {
                        //     paymentController.selectOrCaptureImage(true, true);
                        //   },
                        //   child: Container(
                        //     width: 356.w,
                        //     padding: EdgeInsets.symmetric(
                        //       horizontal: 15.w,
                        //       vertical: 10.h,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: colorConstants.bottomDarkGrayCol,
                        //       borderRadius: BorderRadius.circular(12.r),
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Transform.scale(
                        //           scale: 1.5,
                        //           child: Helper.svgIcon(
                        //             IconConstants.selfieSvg,
                        //             isSelected: false,
                        //             isOriginalColor: true,
                        //             originalColor:
                        //                 colorConstants.secondaryColor,
                        //             height: 30,
                        //             width: 30,
                        //           ),
                        //         ),
                        //         SizedBox(width: 20.w),
                        //         Flexible(
                        //           child: Column(
                        //             crossAxisAlignment:
                        //                 CrossAxisAlignment.start,
                        //             children: [
                        //               CustomText(
                        //                 "Live Selfie",
                        //                 size: 16.sp,
                        //                 fw: FontWeight.w500,
                        //                 color: colorConstants.blackColor,
                        //               ),
                        //               Row(
                        //                 children: [
                        //                   Flexible(
                        //                     child: CustomText(
                        //                       "Take a live selfie of yours",
                        //                       size: 12.sp,
                        //                       fw: FontWeight.w400,
                        //                       color:
                        //                           colorConstants.hintTextColor,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                       