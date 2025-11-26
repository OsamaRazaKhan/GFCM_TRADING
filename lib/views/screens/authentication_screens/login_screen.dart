import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';
import 'package:gfcm_trading/controllers/auth_controller.dart';
import 'package:gfcm_trading/utils/helpers/fingurprint_bottom_sheet.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/forget_password.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthController authController = Get.put(AuthController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController.setUserEmailIdRememberOrNot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(
        init: AuthController(),
        builder: (authController) {
          return Container(
            child: Stack(
              children: [
                CustomImage(
                  height: Get.height,
                  width: Get.width,
                  image: AssetConstants.gfcmLoginImage,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 80.h),
                          CustomImage(
                            height: 132.h,
                            width: 132.w,
                            image: AssetConstants.gfcmLogo,
                          ),
                          SizedBox(height: 60.h),
                          CustomTextFormField(
                            inputTextColor: colorConstants.whiteColor,

                            borderColor: colorConstants.fieldTextColor,
                            isBottomBorder: true,
                            hintText: "Email",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              color: colorConstants.fieldTextColor,
                            ),
                            fillColor: Colors.transparent,
                            validateFunction: authController.emailIdValidate,
                            controller: authController.emailIdController,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
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
                                        if (authController.isIdRemember) {
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
                                      value: authController.isIdRemember,
                                      onChanged: (value) {
                                        authController.rememberId(value!);
                                      },
                                    ),
                                  ),
                                  CustomText(
                                    "Remember User ID",
                                    color: colorConstants.secondaryColor,
                                    fw: FontWeight.w500,
                                    size: 12.sp,
                                  ),
                                ],
                              ),
                              // TextButton(
                              //   onPressed: () {
                              //     authController.rememberId(false);
                              //   },
                              //   child: CustomText(
                              //     color: ColorConstants.secondaryColor,
                              //     "Forget User ID",
                              //     fw: FontWeight.w500,
                              //     size: 12.sp,
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          CustomTextFormField(
                            obSecureTap: () {
                              authController.setObSecure();
                            },
                            isObSecure: authController.isObsecure,
                            inputTextColor: colorConstants.whiteColor,
                            borderColor: colorConstants.fieldTextColor,
                            isBottomBorder: true,
                            hintText: "Password",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              color: colorConstants.fieldTextColor,
                            ),
                            fillColor: Colors.transparent,
                            validateFunction: authController.passwordValidate,
                            controller: authController.passwordController,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.to(() => ForgetPassword());
                                },
                                child: CustomText(
                                  color: colorConstants.secondaryColor,
                                  "Forget Password",
                                  fw: FontWeight.w500,
                                  size: 12.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(
                                child: CustomButton(
                                  height: 50.h,
                                  width: 140.w,
                                  bordercircular: 8.r,
                                  borderColor: colorConstants.primaryColor,
                                  borderWidth: 2.sp,
                                  text: "Login",
                                  textColor: colorConstants.primaryColor,
                                  fw: FontWeight.w500,
                                  fontSize: 14.sp,
                                  boxColor: colorConstants.loginButtonColor,
                                  onTap:
                                      authController.isloginLoading
                                          ? null
                                          : () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              authController.login();
                                            }
                                          },
                                  loader: authController.isloginLoading,
                                ),
                              ),
                              FittedBox(
                                child: CustomButton(
                                  height: 50.h,
                                  width: 140.w,
                                  bordercircular: 8.r,
                                  borderColor: colorConstants.secondaryColor,
                                  borderWidth: 2.sp,
                                  text: "Register",
                                  textColor: colorConstants.primaryColor,
                                  fw: FontWeight.w500,
                                  fontSize: 14.sp,
                                  boxColor: colorConstants.registerButtonColor,
                                  onTap: () {
                                    Get.to(() => RegistrationScreen());
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                height: 80.h,
                                bordercircular: 8.r,
                                borderColor: colorConstants.secondaryColor,
                                borderWidth: 2.sp,
                                icon: Icon(
                                  Icons.fingerprint,
                                  size: 70.sp,
                                  color: colorConstants.primaryColor,
                                ),
                                boxColor: colorConstants.fingurePrintColor,
                                onTap: () {
                                  FingurprintBottomSheet.showBottomSheet(
                                    context,
                                    onlongPressed: () {
                                      authController.fingerprintAuthentication(
                                        context,
                                      );
                                    },
                                  );
                                },
                                sizedBoxWidth: 0.w,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          CustomText(
                            color: colorConstants.whiteColor,
                            "Login With TouchID",
                            fw: FontWeight.w500,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
