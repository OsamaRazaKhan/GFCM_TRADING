import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';

import 'package:gfcm_trading/controllers/auth_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:gfcm_trading/views/custom_widgets/searchable_custom_dropdown_button.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/terms_and_conditions_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  AuthController authController = Get.put(AuthController());
  late FocusScopeNode _focusScopeNode;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusScopeNode = FocusScopeNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.getRegisterScreenInitialData();
    });
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      child: Scaffold(
        backgroundColor: colorConstants.primaryColor,
        body: GetBuilder<AuthController>(
          init: AuthController(),
          builder: (authController) {
            return Form(
              key: formKey,
              child: Container(
                padding: EdgeInsets.only(left: 20.w, right: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50.h),
                      CustomImage(
                        height: 80.h,
                        width: 80.w,
                        image: AssetConstants.gfcmLogo,
                      ),
                      CustomText(
                        "Create Your",
                        color: colorConstants.blackColor,
                        fw: FontWeight.w500,
                        size: 25.sp,
                      ),
                      CustomText(
                        "Account",
                        color: colorConstants.blackColor,
                        fw: FontWeight.w500,
                        size: 25.sp,
                      ),

                      SizedBox(height: 20.h),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  borderColor: colorConstants.fieldBorderColor,
                                  hintText: "First Name",

                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                    color: colorConstants.hintTextColor,
                                  ),
                                  fillColor: colorConstants.fieldColor,
                                  validateFunction:
                                      authController.firstNameValidate,
                                  controller:
                                      authController.firstNameController,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: CustomTextFormField(
                                  borderColor: colorConstants.fieldBorderColor,
                                  hintText: "Last Name",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                    color: colorConstants.hintTextColor,
                                  ),
                                  fillColor: colorConstants.fieldColor,
                                  validateFunction:
                                      authController.lastNamedValidate,
                                  controller: authController.lastNameController,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          CustomTextFormField(
                            borderColor: colorConstants.fieldBorderColor,
                            hintText: "Email",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              color: colorConstants.hintTextColor,
                            ),
                            fillColor: colorConstants.fieldColor,
                            validateFunction: authController.emailValidate,
                            controller: authController.emailController,
                          ),
                          SizedBox(height: 15.h),
                          CustomTextFormField(
                            borderColor: colorConstants.fieldBorderColor,
                            hintText: "Password",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              color: colorConstants.hintTextColor,
                            ),
                            fillColor: colorConstants.fieldColor,
                            validateFunction:
                                authController.regPasswordValidate,
                            controller: authController.regPasswordController,
                          ),

                          SizedBox(height: 15.h),
                          CustomTextFormField(
                            borderColor: colorConstants.fieldBorderColor,
                            hintText: "Re-Password",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              color: colorConstants.hintTextColor,
                            ),
                            fillColor: colorConstants.fieldColor,
                            validateFunction: authController.rePasswordValidate,
                            controller:
                                authController.reEnterPasswordController,
                          ),
                          SizedBox(height: 15.h),
                          SearchAbleCustomDropDownButton(
                            selectedValue: authController.selectedCountry,
                            dropDownButtonList:
                                authController.countriesNameList,
                            text: 'Select Country',
                            textColor: colorConstants.hintTextColor,
                            textSize: 12.sp,
                            textFw: FontWeight.w400,
                            controller: authController,
                            valueType: "Country",
                          ),
                          SizedBox(height: 15.h),
                          authController.isCitiesLoader
                              ? Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorConstants.secondaryColor,
                                  ),
                                ),
                              )
                              : SearchAbleCustomDropDownButton(
                                selectedValue: authController.selectedCity,
                                dropDownButtonList:
                                    authController.citiesNameList,
                                text: 'Select City',
                                textColor: colorConstants.hintTextColor,
                                textSize: 12.sp,
                                textFw: FontWeight.w400,
                                controller: authController,
                                valueType: "City",
                              ),
                          SizedBox(height: 15.h),
                          CustomTextFormField(
                            controller: authController.phoneController,
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Allow only digits
                            ],
                            borderColor: colorConstants.fieldBorderColor,
                            hintText: "3789292992",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              color: colorConstants.hintTextColor,
                            ),
                            fillColor: colorConstants.fieldColor,
                            validateFunction: authController.phoneValidate,

                            child: CountryCodePicker(
                              builder: (countryCode) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: colorConstants.primaryColor,
                                      size: 15.sp,
                                    ),
                                    SizedBox(width: 5.h),
                                    Image.asset(
                                      countryCode?.flagUri ?? '',
                                      package: 'country_code_picker',
                                      height: 18.h,
                                      width: 18.w,
                                    ),
                                    SizedBox(width: 5.h),
                                    CustomText(
                                      "$countryCode",
                                      size: 14.sp,
                                      fw: FontWeight.w400,
                                      color: colorConstants.blackColor,
                                    ),
                                  ],
                                );
                              },
                              onChanged: (code) {
                                authController.setCountryCode(code.toString());
                              },
                              initialSelection: authController.countryCode,
                              favorite: const ['+92'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          CustomTextFormField(
                            readOnly: true,
                            borderColor: colorConstants.fieldBorderColor,
                            hintText: "Referral code",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              color: colorConstants.hintTextColor,
                            ),
                            fillColor: colorConstants.fieldColor,
                            controller: authController.referalCodeController,
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),

                      // CustomText(
                      //   "Choose Trading Type:",
                      //   size: 14.sp,
                      //   fw: FontWeight.w400,
                      //   color: colorConstants.blackColor,
                      // ),
                      // SizedBox(height: 6.h),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          children: [
                            CheckboxTheme(
                              data: CheckboxThemeData(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    4.r,
                                  ), // Optional, to make the border rounded
                                  side: BorderSide(
                                    color:
                                        colorConstants
                                            .boxgryColor, // #1B0D38 with 15% opacity
                                    width: 1.5.w, // Border width
                                  ),
                                ),
                                fillColor: WidgetStateProperty.resolveWith((
                                  states,
                                ) {
                                  if (authController.isAgreeWithTerms) {
                                    return colorConstants
                                        .secondaryColor; // Tick color when selected
                                  }
                                  return Colors
                                      .transparent; // Background color when unchecked
                                }),
                                checkColor: WidgetStateProperty.all(
                                  colorConstants.blackColor,
                                ), // Tick color
                              ),
                              child: Checkbox(
                                value: authController.isAgreeWithTerms,
                                onChanged: (value) {
                                  authController.agreeWithTermsAndCondition(
                                    value!,
                                  );
                                },
                                side: BorderSide(
                                  color: colorConstants.boxgryColor,
                                  width: 1.5.w,
                                ),
                              ),
                            ),

                            Expanded(
                              child: CustomText(
                                "I agree to the Terms of Services and Privacy Policy",
                                color: colorConstants.hintTextColor,
                                fw: FontWeight.w400,
                                size: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (context) => TermsAndConditionsDialog(),
                              );
                            },
                            child: CustomText(
                              "Terms and Conditions",
                              color: colorConstants.blueColor,
                              fw: FontWeight.w500,
                              size: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),

                      Align(
                        alignment: Alignment.center,
                        child: CustomButton(
                          height: 44.h,
                          width: 250.w,
                          bordercircular: 10.r,
                          borderColor: Colors.transparent,
                          borderWidth: 2.sp,
                          text: "Submit",
                          textColor: colorConstants.primaryColor,
                          fontSize: 14.sp,
                          fw: FontWeight.w500,
                          boxColor: colorConstants.secondaryColor,
                          onTap:
                              authController.isRegisterloading
                                  ? null
                                  : () async {
                                    if (formKey.currentState!.validate()) {
                                      await Future.delayed(
                                        Duration(milliseconds: 100),
                                      );

                                      authController.registerUser(context);
                                    }
                                  },
                          loader: authController.isRegisterloading,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            "Already have an account",
                            color: colorConstants.hintTextColor,
                            fw: FontWeight.w400,
                            size: 14.sp,
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: CustomText(
                              "Login",
                              color: colorConstants.blueColor,
                              fw: FontWeight.w500,
                              size: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
