import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';

import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/referals_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:gfcm_trading/views/custom_widgets/searchable_custom_dropdown_button.dart';

class ReferalsScreen extends StatefulWidget {
  String? firstName;
  String? lastName;
  ReferalsScreen({super.key, this.firstName, this.lastName});

  @override
  State<ReferalsScreen> createState() => _ReferalsScreenState();
}

class _ReferalsScreenState extends State<ReferalsScreen> {
  ReferalsController referalsController = Get.put(ReferalsController());

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      referalsController.getReferralsDetail();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        referalsController.getYourReferrals(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomImage(
          height: 55.h,
          width: 55.w,
          image: AssetConstants.gfcmLogo,
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: CustomText(
                  "Help",
                  size: 18.sp,
                  fw: FontWeight.w400,
                  color: colorConstants.blueColor,
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: GetBuilder<ReferalsController>(
        init: ReferalsController(),
        builder: (referalsController) {
          return Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.all(15.r),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Reference",
                      size: 22.sp,
                      fw: FontWeight.w500,
                      color: colorConstants.blackColor,
                    ),
                    SizedBox(height: 30.h),
                    Container(
                      // height: 229.h,
                      decoration: BoxDecoration(
                        color: colorConstants.bottomDarkGrayCol,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10.r),
                            child: CustomText(
                              "${widget.firstName ?? ""} ${widget.lastName ?? ""}",
                              size: 18.sp,
                              fw: FontWeight.w500,
                              color: colorConstants.blackColor,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.1),
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.all(10.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: CustomText(
                                              "Total Registrations",
                                              size: 12.sp,
                                              fw: FontWeight.w400,
                                              color:
                                                  colorConstants.hintTextColor,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Flexible(
                                            child: CustomText(
                                              referalsController
                                                  .referralsLength,
                                              size: 11.sp,
                                              fw: FontWeight.w700,
                                              color: colorConstants.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: CustomText(
                                              "Active Accounts",
                                              size: 12.sp,
                                              fw: FontWeight.w400,
                                              color:
                                                  colorConstants.hintTextColor,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Flexible(
                                            child: CustomText(
                                              referalsController.activeCounts,
                                              size: 11.sp,
                                              fw: FontWeight.w700,
                                              color: colorConstants.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: CustomText(
                                              "Total Deposits",
                                              size: 12.sp,
                                              fw: FontWeight.w400,
                                              color:
                                                  colorConstants.hintTextColor,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Flexible(
                                            child: CustomText(
                                              referalsController.totalDeposit,
                                              size: 11.sp,
                                              fw: FontWeight.w700,
                                              color: colorConstants.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: CustomText(
                                              "Lot Size",
                                              size: 12.sp,
                                              fw: FontWeight.w400,
                                              color:
                                                  colorConstants.hintTextColor,
                                            ),
                                          ),
                                          SizedBox(width: 43.w),
                                          Flexible(
                                            child: CustomText(
                                              referalsController.totalLots,
                                              size: 11.sp,
                                              fw: FontWeight.w700,
                                              color: colorConstants.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                CustomButton(
                                  icon: Icon(
                                    Icons.copy_all_rounded,
                                    color: colorConstants.primaryColor,
                                    size: 20.sp,
                                  ),
                                  height: 35.h,
                                  width: 130.w,
                                  bordercircular: 10.r,
                                  borderColor: Colors.transparent,
                                  borderWidth: 2.sp,
                                  text: "Copy Url",
                                  textColor: colorConstants.primaryColor,
                                  fontSize: 12.sp,
                                  fw: FontWeight.w500,
                                  boxColor: colorConstants.secondaryColor,
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            "https://gfcmtrading.web.app/referral/?ref=${referalsController.referalCode}",
                                      ),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: CustomText(
                                          "Referal code copied!",
                                          color: colorConstants.primaryColor,
                                        ),
                                        backgroundColor:
                                            colorConstants.secondaryColor,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                referalsController.hideFilter();
                              },
                              child: Transform.scale(
                                scale: 0.6,
                                child: Helper.svgIcon(
                                  IconConstants.filterSvg,
                                  isSelected: false,
                                  isOriginalColor: true,
                                  originalColor:
                                      referalsController.isFilterHide
                                          ? colorConstants.blackColor
                                          : colorConstants.hintTextColor,
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                            SizedBox(width: 1.w),
                            CustomText(
                              "Filter",
                              size: 16.sp,
                              fw: FontWeight.w500,
                              color:
                                  referalsController.isFilterHide
                                      ? colorConstants.blackColor
                                      : colorConstants.hintTextColor,
                            ),
                          ],
                        ),
                        Visibility(
                          visible: referalsController.isFilterHide,
                          child: CustomButton(
                            height: 27.h,
                            width: 85.w,
                            bordercircular: 3.r,
                            borderColor: Colors.transparent,
                            borderWidth: 2.sp,
                            text: "Clear Filter",
                            textColor: colorConstants.redColor,
                            boxColor: colorConstants.bottomDarkGrayCol,
                            onTap: () {
                              referalsController.clearFilter();
                            },
                            fontSize: 12.sp,
                            fw: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Visibility(
                      visible: referalsController.isFilterHide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            "Country",
                            size: 16.sp,
                            fw: FontWeight.w400,
                          ),
                          SizedBox(height: 5.h),
                          SearchAbleCustomDropDownButton(
                            selectedValue: referalsController.selectedCountry,
                            dropDownButtonList:
                                referalsController.countriesNameList,
                            text: 'Select Country',
                            textColor: colorConstants.hintTextColor,
                            textSize: 12.sp,
                            textFw: FontWeight.w400,
                            controller: referalsController,
                            valueType: "Country",
                          ),

                          SizedBox(height: 10.h),
                          CustomText("Name", size: 16.sp, fw: FontWeight.w400),
                          SizedBox(height: 5.h),

                          SearchAbleCustomDropDownButton(
                            selectedValue: referalsController.selectedRefName,
                            dropDownButtonList:
                                referalsController.referralsNameList,
                            text: 'Select Name',
                            textColor: colorConstants.hintTextColor,
                            textSize: 12.sp,
                            textFw: FontWeight.w400,
                            controller: referalsController,
                            valueType: "Name",
                          ),

                          SizedBox(height: 10.h),
                          CustomText(
                            "Registration Period",
                            size: 16.sp,
                            fw: FontWeight.w400,
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  borderColor: colorConstants.fieldBorderColor,
                                  hintText: "Start Date",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                    color: colorConstants.hintTextColor,
                                  ),
                                  fillColor: colorConstants.fieldColor,
                                  validateFunction:
                                      referalsController.startDateValidate,
                                  controller:
                                      referalsController.startDateController,
                                  icon: Icon(
                                    Icons.event,
                                    color: colorConstants.hintTextColor,
                                  ),
                                  suffixTapAction: () {
                                    referalsController.selectDate(
                                      context,
                                      referalsController.startDateController,
                                    );
                                  },
                                  onTap: () {
                                    referalsController.selectDate(
                                      context,
                                      referalsController.startDateController,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: CustomTextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  borderColor: colorConstants.fieldBorderColor,
                                  hintText: "End Date",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                    color: colorConstants.hintTextColor,
                                  ),
                                  fillColor: colorConstants.fieldColor,
                                  validateFunction:
                                      referalsController.endDateValidate,
                                  controller:
                                      referalsController.endDateController,
                                  icon: Icon(
                                    Icons.event,
                                    color: colorConstants.hintTextColor,
                                  ),
                                  suffixTapAction: () {
                                    referalsController.selectDate(
                                      context,
                                      referalsController.endDateController,
                                    );
                                  },
                                  onTap: () {
                                    referalsController.selectDate(
                                      context,
                                      referalsController.endDateController,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          CustomButton(
                            height: 38.h,
                            width: 100.w,
                            bordercircular: 10.r,
                            borderColor: Colors.transparent,
                            borderWidth: 2.sp,
                            text: "Apply",
                            textColor: colorConstants.primaryColor,
                            fontSize: 14.sp,
                            fw: FontWeight.w500,
                            boxColor: colorConstants.secondaryColor,
                            onTap:
                                referalsController.isFilterLoader
                                    ? null
                                    : () {
                                      if (formKey.currentState!.validate()) {
                                        referalsController.getYourReferrals(
                                          isFilter: true,
                                        );
                                      }
                                    },
                            loader: referalsController.isFilterLoader,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomText(
                            "Name",
                            size: 16.sp,
                            fw: FontWeight.w700,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: CustomText(
                            "ID",
                            size: 16.sp,
                            fw: FontWeight.w700,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: CustomText(
                            "Status",
                            size: 16.sp,
                            fw: FontWeight.w700,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: colorConstants.dimGrayColor),
                    SizedBox(
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount:
                            referalsController.yourReferralsList.length +
                            (referalsController.hasReferralMoreData
                                ? 1
                                : 0), // +1 for loader
                        itemBuilder: (context, index) {
                          if (index <
                              referalsController.yourReferralsList.length) {
                            final referrals =
                                referalsController.yourReferralsList[index];
                            if (referalsController.yourReferralsList.isEmpty &&
                                !referalsController.isReferalLoadingMore) {
                              return Center(
                                child: CustomText(
                                  "No Referrals found",
                                  color: colorConstants.hintTextColor,
                                ),
                              );
                            }
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CustomText(
                                        "${referrals.firstname ?? ""} ${referrals.lastname ?? ""}",
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.hintTextColor,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomText(
                                        referrals.id.toString() ?? "",
                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.hintTextColor,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomText(
                                        referrals.balance == "" ||
                                                referrals.balance == null
                                            ? "Not Active"
                                            : "Active",

                                        size: 12.sp,
                                        fw: FontWeight.w400,
                                        color: colorConstants.hintTextColor,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.w,
                                  ), // Adjust as needed
                                  child: Divider(
                                    color: colorConstants.hintTextColor,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Loader at the end
                            return Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorConstants.secondaryColor,
                                ),
                              ),
                            );
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
  }
}
