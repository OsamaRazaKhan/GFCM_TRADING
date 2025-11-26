import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/auth_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_circular_avatar_widget.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:gfcm_trading/views/custom_widgets/searchable_custom_dropdown_button.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  AuthController authController = Get.put(AuthController());
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController.getUserData();
  }

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
          "Update Profile",
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
              padding: EdgeInsets.only(left: 20.w, right: 20),
              child:
                  authController.isGetUserloading
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorConstants.secondaryColor,
                            ),
                          ),
                        ),
                      )
                      : authController.userData == null
                      ? Center(
                        child: CustomEmptyScreenMessage(
                          icon: Icon(
                            Icons.cloud_off, // General error icon
                            size: 80.sp,
                            color: colorConstants.hintTextColor,
                          ),
                          headText: "Oops! Something Went Wrong",
                          subtext:
                              "Please try again later or refresh the page.",
                          onTap: () {
                            authController.getUserData();
                          },
                        ),
                      )
                      : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        children: [
                                          CustomCircularAvatarWidget(
                                            height: 80.h,
                                            width: 80.h,
                                            image:
                                                authController
                                                            .userData?["profile"] !=
                                                        null
                                                    ? "https://backend.gfcmgroup.com/${authController.userData?["profile"]}"
                                                    : null,
                                            localImage:
                                                authController.profileImage,
                                            isNetwork: true,
                                            isAsset: false,
                                            boxColor: colorConstants.lightGray,
                                          ),
                                          Positioned(
                                            left: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                authController
                                                    .selectProfileImage();
                                              },
                                              child: Container(
                                                height: 28.h,
                                                width: 28.w,
                                                decoration: BoxDecoration(
                                                  color:
                                                      colorConstants
                                                          .secondaryColor, // Background color
                                                  shape:
                                                      BoxShape
                                                          .circle, // Makes it circular (optional)
                                                ),
                                                child: Icon(
                                                  Icons.edit_outlined,
                                                  color:
                                                      colorConstants
                                                          .primaryColor,
                                                  size: 12.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 35.h),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                              readOnly: true,

                                              borderColor:
                                                  colorConstants
                                                      .fieldBorderColor,
                                              hintText: "First Name",

                                              hintStyle: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12.sp,
                                                color:
                                                    colorConstants
                                                        .hintTextColor,
                                              ),
                                              fillColor:
                                                  colorConstants.fieldColor,
                                              validateFunction:
                                                  authController
                                                      .firstNameValidate,
                                              controller:
                                                  authController
                                                      .firstNameController,
                                            ),
                                          ),
                                          SizedBox(width: 20.w),
                                          Expanded(
                                            child: CustomTextFormField(
                                              readOnly: true,
                                              borderColor:
                                                  colorConstants
                                                      .fieldBorderColor,
                                              hintText: "Last Name",
                                              hintStyle: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12.sp,
                                                color:
                                                    colorConstants
                                                        .hintTextColor,
                                              ),
                                              fillColor:
                                                  colorConstants.fieldColor,
                                              validateFunction:
                                                  authController
                                                      .lastNamedValidate,
                                              controller:
                                                  authController
                                                      .lastNameController,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 25.h),
                                      CustomTextFormField(
                                        readOnly: true,
                                        borderColor:
                                            colorConstants.fieldBorderColor,
                                        hintText: "Email",
                                        hintStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          color: colorConstants.hintTextColor,
                                        ),
                                        fillColor: colorConstants.fieldColor,
                                        validateFunction:
                                            authController.emailValidate,
                                        controller:
                                            authController.emailController,
                                      ),
                                      SizedBox(height: 25.h),
                                      CustomTextFormField(
                                        borderColor:
                                            colorConstants.fieldBorderColor,
                                        hintText: "Password",
                                        hintStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          color: colorConstants.hintTextColor,
                                        ),
                                        fillColor: colorConstants.fieldColor,
                                        validateFunction:
                                            authController.regPasswordValidate,
                                        controller:
                                            authController
                                                .regPasswordController,
                                        obSecureTap: () {
                                          authController.setObSecure();
                                        },
                                        isObSecure: authController.isObsecure,
                                      ),

                                      SizedBox(height: 25.h),
                                      SearchAbleCustomDropDownButton(
                                        selectedValue:
                                            authController.selectedCountry,
                                        dropDownButtonList:
                                            authController.countriesNameList,
                                        text: 'Select Country',
                                        textColor: colorConstants.hintTextColor,
                                        textSize: 12.sp,
                                        textFw: FontWeight.w400,
                                        controller: authController,
                                        valueType: "Country",
                                      ),
                                      SizedBox(height: 25.h),
                                      authController.isCitiesLoader
                                          ? Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color:
                                                    colorConstants
                                                        .secondaryColor,
                                              ),
                                            ),
                                          )
                                          : SearchAbleCustomDropDownButton(
                                            selectedValue:
                                                authController.selectedCity,
                                            dropDownButtonList:
                                                authController.citiesNameList,
                                            text: 'Select City',
                                            textColor:
                                                colorConstants.hintTextColor,
                                            textSize: 12.sp,
                                            textFw: FontWeight.w400,
                                            controller: authController,
                                            valueType: "City",
                                          ),
                                      SizedBox(height: 25.h),
                                      CustomTextFormField(
                                        readOnly: true,
                                        controller:
                                            authController.phoneController,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly, // Allow only digits
                                        ],
                                        borderColor:
                                            colorConstants.fieldBorderColor,
                                        hintText: "3789292992",
                                        hintStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          color: colorConstants.hintTextColor,
                                        ),
                                        fillColor: colorConstants.fieldColor,
                                        validateFunction:
                                            authController.phoneValidate,

                                        child: CountryCodePicker(
                                          builder: (countryCode) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color:
                                                      colorConstants
                                                          .primaryColor,
                                                  size: 15.sp,
                                                ),
                                                SizedBox(width: 5.h),
                                                Image.asset(
                                                  countryCode?.flagUri ?? '',
                                                  package:
                                                      'country_code_picker',
                                                  height: 18.h,
                                                  width: 18.w,
                                                ),
                                                SizedBox(width: 5.h),
                                                CustomText(
                                                  "$countryCode",
                                                  size: 14.sp,
                                                  fw: FontWeight.w400,
                                                  color:
                                                      colorConstants.blackColor,
                                                ),
                                              ],
                                            );
                                          },
                                          onChanged: (code) {
                                            authController.setCountryCode(
                                              code.toString(),
                                            );
                                          },
                                          initialSelection:
                                              authController.countryCode,
                                          favorite: const ['+92'],
                                          showCountryOnly: false,
                                          showOnlyCountryWhenClosed: false,
                                          alignLeft: false,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // CustomText(
                                  //   "Choose Trading Type:",
                                  //   size: 14.sp,
                                  //   fw: FontWeight.w400,
                                  //   color: colorConstants.blackColor,
                                  // ),
                                  // SizedBox(height: 6.h),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Expanded(
                                  //       child: CustomRadioButton(
                                  //         status: "Manual",
                                  //         controller: authController,
                                  //       ),
                                  //     ),
                                  //     Expanded(
                                  //       child: CustomRadioButton(
                                  //         status: "By GFCM",
                                  //         controller: authController,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: CustomButton(
                              height: 44.h,
                              width: 250.w,
                              bordercircular: 10.r,
                              borderColor: Colors.transparent,
                              borderWidth: 2.sp,
                              text: "Update",
                              textColor: colorConstants.primaryColor,
                              fontSize: 14.sp,
                              fw: FontWeight.w500,
                              boxColor: colorConstants.secondaryColor,
                              onTap:
                                  authController.isUpdateUserloading
                                      ? null
                                      : () {
                                        authController.updateUserProfile();
                                      },
                              loader: authController.isUpdateUserloading,
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
            ),
          );
        },
      ),
    );
  }
}
