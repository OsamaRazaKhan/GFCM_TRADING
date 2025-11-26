import 'dart:convert';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/services/authentication_service.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/utils/helpers/auth_success_dialog.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/registration_screen.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/reset_password_screen.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/verification_code_screen.dart';
import 'package:gfcm_trading/views/screens/bottom_nav_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  ColorConstants colorConstants = ColorConstants();
  bool isIdRemember = false;
  Set<String> uniqueCountries = {};
  List<String> countriesNameList = [];
  Set<String> uniqueCities = {};
  List<String> citiesNameList = [];
  Map<String, dynamic>? userData;
  final ImagePicker picker = ImagePicker();
  File? profileImage;
  String existingProfileImage = "";
  bool isCitiesLoader = false;

  TextEditingController emailIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController regPasswordController = TextEditingController();
  TextEditingController reEnterPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController forgetEmailController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController referalCodeController = TextEditingController();
  bool isObsecure = true;
  String? selectedCountry;
  String? selectedCity;
  String countryCode = "+92";
  final LocalAuthentication auth = LocalAuthentication();
  String? selectedStatus = "By GFCM";
  bool isAgreeWithTerms = false;

  bool isRegisterloading = false;
  bool isloginLoading = false;
  bool isSendCodeLoading = false;
  bool isVerifyCodeLoading = false;
  bool isResetLoading = false;
  bool isGetUserloading = false;
  bool isUpdateUserloading = false;
  AppLinks? _appLinks; //  make nullable

  // onClose() {
  //   emailIdController.dispose();
  //   passwordController.dispose();
  //   firstNameController.dispose();
  //   lastNameController.dispose();
  //   emailController.dispose();
  //   regPasswordController.dispose();
  //   reEnterPasswordController.dispose();
  //   phoneController.dispose();
  //   forgetEmailController.dispose();
  //   codeController.dispose();
  //   newPasswordController.dispose();
  //   confirmPasswordController.dispose();
  //   super.onClose();
  // }

  /*---------------------------------------------------------------*/
  /*                  get ref code through deep link               */
  /*---------------------------------------------------------------*/

  // Future<void> getRegisterScreenInitialData() async {
  //   //  Only initialize once
  //   _appLinks ??= AppLinks();

  //   //  Handle deep links when the app is already running
  //   _appLinks!.uriLinkStream.listen((uri) {
  //     if (_isReferralLink(uri)) _handleDeepLink(uri);
  //   });

  //   //  Handle deep link only if app launched *from deep link*
  //   await _checkIfColdStartFromDeepLink();

  //   getCountries();
  // }
  Future<void> getRegisterScreenInitialData() async {
    //  Only initialize once
    _appLinks ??= AppLinks();

    // Handle deep links when the app is already running
    _appLinks!.uriLinkStream.listen((uri) {
      if (_isReferralLink(uri)) _handleDeepLink(uri);
    });

    // Handle deep link if app launched freshly
    await _checkIfColdStartFromDeepLink();

    getCountries();
  }

  Future<void> _checkIfColdStartFromDeepLink() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = await _appLinks!.getInitialLink();

    if (uri != null && _isReferralLink(uri)) {
      final lastLink = prefs.getString("last_deep_link");
      if (lastLink != uri.toString()) {
        await prefs.setString("last_deep_link", uri.toString());
        _handleDeepLink(uri);
      }
    } else {
      await prefs.remove("last_deep_link");
    }
  }

  bool _isReferralLink(Uri uri) {
    return uri.path.contains("referral") && uri.queryParameters["ref"] != null;
  }

  void _handleDeepLink(Uri uri) {
    final code = uri.queryParameters["ref"];
    if (code == null || code.isEmpty) return;

    referalCodeController.text = code;

    if (Get.currentRoute != '/RegistrationScreen') {
      Get.to(() => RegistrationScreen());
    }

    update();
  }

  // ///  Only handle link if the app was launched *freshly* via deep link
  // Future<void> _checkIfColdStartFromDeepLink() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // Track whether app was opened normally (not via link)
  //   final uri = await _appLinks!.getInitialLink();

  //   if (uri != null && _isReferralLink(uri)) {
  //     final lastLink = prefs.getString("last_deep_link");
  //     if (lastLink != uri.toString()) {
  //       await prefs.setString("last_deep_link", uri.toString());
  //       _handleDeepLink(uri);
  //     }
  //   } else {
  //     //  Clear the last_deep_link if app opened normally
  //     await prefs.remove("last_deep_link");
  //   }
  // }

  // bool _isReferralLink(Uri uri) {
  //   return uri.path.contains("referral") && uri.queryParameters["ref"] != null;
  // }

  // void _handleDeepLink(Uri uri) {
  //   final code = uri.queryParameters["ref"];
  //   if (code == null || code.isEmpty) return;

  //   referalCodeController.text = code;

  //   //  Only navigate if not already on the Registration screen
  //   if (Get.currentRoute != '/RegistrationScreen') {
  //     Get.to(() => RegistrationScreen());
  //   }

  //   update();
  // }

  void rememberId(bool value) async {
    isIdRemember = value;
    if (isIdRemember) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString("emailId", emailIdController.text.trim());
      sp.setBool("isIdRemember", isIdRemember);
      isIdRemember = sp.getBool("isIdRemember") ?? true;
      update();
    } else {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.remove("emailId");
      sp.setBool("isIdRemember", isIdRemember);
      isIdRemember = sp.getBool("isIdRemember") ?? false;
      update();
    }
  }

  void agreeWithTermsAndCondition(bool value) {
    isAgreeWithTerms = value;
    update();
  }

  /*--------------------------------------------------------------*/
  /*                       select profile image                   */
  /*--------------------------------------------------------------*/
  Future<void> selectProfileImage() async {
    try {
      // Request camera permission
      if (Platform.isAndroid) {
        // Try photos permission (Android 13+)
        final photoStatus = await Permission.photos.request();
        if (!photoStatus.isGranted) {
          // Fallback to storage permission (Android 12 or lower)
          final storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            FlushMessages.commonToast(
              "Gallery permission is required to upload images.",
              backGroundColor: colorConstants.dimGrayColor,
            );
            return;
          }
        }
      }
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front,
      );
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
        update();
      }
    } catch (e) {
      FlushMessages.commonToast(
        "Failed to pick image. Please try again.",
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*-------------------------------------------------------------*/
  /*                       set country code                      */
  /*-------------------------------------------------------------*/
  void setCountryCode(value) {
    countryCode = value;
    update();
  }

  /*-------------------------------------------------------------*/
  /*                     select trading type                      */
  /*--------------------------------------------------------------*/
  void selectStatus(String value) {
    selectedStatus = value;
    update();
  }

  /*-------------------------------------------------------------*/
  /*                   fingur print logic                        */
  /*-------------------------------------------------------------*/

  Future<void> fingerprintAuthentication(BuildContext context) async {
    try {
      bool isAvailable = await auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      print('Biometrics available: $availableBiometrics');

      if (isAvailable &&
          (availableBiometrics.contains(BiometricType.fingerprint) ||
              availableBiometrics.contains(BiometricType.strong))) {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Scan your fingerprint to authenticate',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (authenticated) {
          FlushMessages.commonToast(
            "Authentication successful!",
            backGroundColor: colorConstants.dimGrayColor,
          );

          // Example: Navigate or call your login method
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          FlushMessages.commonToast(
            "Authentication failed.",
            backGroundColor: colorConstants.dimGrayColor,
          );
        }
      } else {
        FlushMessages.commonToast(
          "Fingerprint not available.",
          backGroundColor: colorConstants.dimGrayColor,
        );
      }
    } catch (e) {
      FlushMessages.commonToast(
        'Error: $e',
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/

  String? emailIdValidate(value) {
    bool emailReg = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value);
    if (value == null || value.trim().isEmpty) {
      return "Must enter your email";
    } else if (emailReg == false) {
      return "Please enter valid email";
    }
    return null;
  }

  String? passwordValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter your password";
    }
    return null;
  }

  String? regPasswordValidate(value) {
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@!%*?&])[A-Za-z\d#$@!%*?&]{8,}$',
    );
    bool password = passwordRegex.hasMatch(value);
    if (value == null || value.trim().isEmpty) {
      return "Please must enter your password";
    } else if (password == false) {
      return "Password must contain 8 characters, including uppercase, lowercase, a number, and a special character";
    }
    return null;
  }

  String? rePasswordValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must reEnter your password";
    }
    return null;
  }

  String? firstNameValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Must enter first name";
    }
    return null;
  }

  String? lastNamedValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Must enter last name";
    }
    return null;
  }

  String? emailValidate(value) {
    bool emailReg = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value);
    if (value == null || value.trim().isEmpty) {
      return "Must enter your email";
    } else if (emailReg == false) {
      return "Please enter valid email";
    }
    return null;
  }

  String? phoneValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter phone number";
    }
    return null; // Valid input
  }

  String? codeValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Kindly enter the verification code sent to your email address";
    }
    return null;
  }

  String? newPasswordValidate(value) {
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@!%*?&])[A-Za-z\d#$@!%*?&]{8,}$',
    );
    bool password = passwordRegex.hasMatch(value);
    if (value == null || value.trim().isEmpty) {
      return "Please must enter new password";
    } else if (password == false) {
      return "Password must contain 8 characters, including uppercase, lowercase, a number, and a special character";
    }
    return null;
  }

  String? confirmPasswordValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter confirm password";
    }
    return null;
  }

  /*----------------------------------------------------------------------*/
  /*                          set obsecure value                          */
  /*----------------------------------------------------------------------*/
  void setObSecure() {
    isObsecure = !isObsecure;
    update();
  }

  /*----------------------------------------------------------------------*/
  /*                 select value from search able dropdown               */
  /*----------------------------------------------------------------------*/
  void selectValueFromSearchAbleDropDown(String valueType, String value) {
    if (valueType == 'Country') {
      selectedCountry = value;
      update();
      getCities(value);
    }
    if (valueType == 'City') {
      selectedCity = value;

      update();
    }
  }

  void setUserEmailIdRememberOrNot() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    isIdRemember = sp.getBool("isIdRemember") ?? false;
    if (isIdRemember) {
      emailIdController.text = sp.getString("emailId") ?? "";
    }
    update();
  }

  /*----------------------------------------------------------------------*/
  /*                            get countries logic                       */
  /*----------------------------------------------------------------------*/
  Future<void> getCountries() async {
    try {
      countriesNameList.clear();
      uniqueCountries.clear();
      update();
      var response = await AuthenticationService.getCountriesApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          if (responseData['Result'] == "true") {
            for (int i = 0; i < responseData['Data'].length; i++) {
              final country = responseData['Data'][i]['country'];
              if (country != null && uniqueCountries.add(country)) {
                countriesNameList.add(country);
              }
            }
            update();
          } else {
            countriesNameList.clear();
            uniqueCountries.clear();
            update();
          }
        } else {
          countriesNameList.clear();
          uniqueCountries.clear();
          update();
        }
      } else {
        countriesNameList.clear();
        uniqueCountries.clear();
        update();
      }
    } catch (e) {
      countriesNameList.clear();
      uniqueCountries.clear();
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                             get cities logic                          */
  /*----------------------------------------------------------------------*/
  Future<void> getCities(String country) async {
    try {
      isCitiesLoader = true;
      citiesNameList.clear();
      uniqueCities.clear();
      update();
      var response = await AuthenticationService.getCitiesApi(country);
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          if (responseData['Result'] == "true") {
            for (int i = 0; i < responseData['Data'].length; i++) {
              final city = responseData['Data'][i]['city'];
              if (city != null && uniqueCities.add(city)) {
                citiesNameList.add(city);
              }
            }
            update();
          } else {
            citiesNameList.clear();
            uniqueCities.clear();
            update();
          }
        } else {
          citiesNameList.clear();
          uniqueCities.clear();
          update();
        }
      } else {
        citiesNameList.clear();
        uniqueCities.clear();
        update();
      }
    } catch (e) {
      citiesNameList.clear();
      uniqueCities.clear();
      update();
    } finally {
      isCitiesLoader = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                           register user logic                        */
  /*----------------------------------------------------------------------*/
  Future<void> registerUser(BuildContext context) async {
    try {
      if (isAgreeWithTerms) {
        if (selectedCountry == null) {
          FlushMessages.commonToast(
            "Please select a country",
            backGroundColor: colorConstants.dimGrayColor,
          );
        } else if (selectedCity == null) {
          FlushMessages.commonToast(
            "Please select a city",
            backGroundColor: colorConstants.dimGrayColor,
          );
        } else if (selectedStatus == null) {
          FlushMessages.commonToast(
            "Please choose a trading type",
            backGroundColor: colorConstants.dimGrayColor,
          );
        } else if (regPasswordController.text.trim() !=
            reEnterPasswordController.text.trim()) {
          FlushMessages.commonToast(
            "Passwords do not match. Please re-enter",
            backGroundColor: colorConstants.dimGrayColor,
          );
        } else {
          isRegisterloading = true;
          update();
          var response = await AuthenticationService.registerUserApi(
            firstNameController.text.trim(),
            lastNameController.text.trim(),
            emailController.text.trim(),
            regPasswordController.text.trim(),
            selectedCountry!,
            selectedCity!,
            countryCode,
            phoneController.text.trim(),
            selectedStatus!,
            referalCodeController.text.trim(),
          );
          if (response != null) {
            if (response.statusCode == 201) {
              FlushMessages.commonToast(
                "You have registered successfully",
                backGroundColor: colorConstants.secondaryColor,
              );
              isRegisterloading = false;
              var responseData = jsonDecode(response.body);

              var userId = responseData["userId"];

              update();

              AuthSuccessDialog.showSuccessDialog(
                context,
                isRegister: true,
                userId: "GFCM-$userId",
                password: regPasswordController.text.trim(),
                server: "GFCM-Server",
              );
            } else {
              var data = jsonDecode(response.body);
              FlushMessages.commonToast(
                data['message'],
                backGroundColor: colorConstants.dimGrayColor,
              );
              isRegisterloading = false;

              update();
            }
          } else {
            FlushMessages.commonToast(
              "Something went wrong please try again",
              backGroundColor: colorConstants.dimGrayColor,
            );
            isRegisterloading = false;

            update();
          }
        }
      } else {
        FlushMessages.commonToast(
          "Kindly agree to the terms and conditions to continue",
          backGroundColor: colorConstants.dimGrayColor,
        );
      }
    } catch (e) {
      FlushMessages.commonToast(
        "$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
    } finally {
      isRegisterloading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                            login user logic                          */
  /*----------------------------------------------------------------------*/
  Future<void> login() async {
    try {
      if (isIdRemember) {
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString("emailId", emailIdController.text.trim());
        sp.setBool("isIdRemember", true);
      } else {
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.remove("emailId");
        sp.setBool("isIdRemember", false);
      }
      isloginLoading = true;
      update();
      var response = await AuthenticationService.loginApi(
        emailIdController.text.trim(),
        passwordController.text.trim(),
      );
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("userId", responseData['userId'].toString());

          Get.put(TradeChartController()).loadChartDataFunction();

          FlushMessages.commonToast(
            "You have successfully logged in",
            backGroundColor: colorConstants.secondaryColor,
          );
          isloginLoading = false;
          update();
          emailIdController.clear();
          passwordController.clear();
          Get.offAll(() => bottomNavScreen());
        } else {
          var responseData = jsonDecode(response.body);
          FlushMessages.commonToast(
            responseData['message'],
            backGroundColor: colorConstants.dimGrayColor,
          );
          isloginLoading = false;
          update();
        }
      } else {
        FlushMessages.commonToast(
          "Something went wrong please try again",
          backGroundColor: colorConstants.dimGrayColor,
        );
        isloginLoading = false;
        update();
      }
    } catch (e) {
      FlushMessages.commonToast(
        "$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
      isloginLoading = false;
      update();
    } finally {
      isloginLoading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                 forgot password (get code base on email)              */
  /*----------------------------------------------------------------------*/
  void sendEmailAndGetCode() async {
    try {
      isSendCodeLoading = true;
      update();
      var response = await AuthenticationService.getCodeApi(
        forgetEmailController.text.trim(),
      );
      if (response != null) {
        if (response.statusCode == 200) {
          FlushMessages.commonToast(
            "Check your email for the 6-digit verification code",
            backGroundColor: colorConstants.secondaryColor,
          );
          isSendCodeLoading = false;
          update();

          Get.off(
            () => VerificationCodeScreen(
              email: forgetEmailController.text.trim(),
            ),
          );
        } else {
          var responseData = jsonDecode(response.body);
          FlushMessages.commonToast(
            responseData['message'],
            backGroundColor: colorConstants.dimGrayColor,
          );
          isSendCodeLoading = false;
          update();
        }
      } else {
        FlushMessages.commonToast(
          "Something went wrong please try again",
          backGroundColor: colorConstants.dimGrayColor,
        );
        isSendCodeLoading = false;
        update();
      }
    } catch (e) {
      FlushMessages.commonToast(
        "$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
      isSendCodeLoading = false;
      update();
    } finally {
      isSendCodeLoading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                          code verification logic                     */
  /*----------------------------------------------------------------------*/
  void verifyYourCode(BuildContext context, String? email) async {
    try {
      isVerifyCodeLoading = true;
      update();
      var response = await AuthenticationService.verifyYourCodeApi(
        codeController.text.trim(),
        email,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            FlushMessages.commonToast(
              "The verification code has been successfully verified",
              backGroundColor: colorConstants.secondaryColor,
            );
            isVerifyCodeLoading = false;
            update();
            String id = responseData['id'].toString();

            Get.off(() => ResetPasswordScreen(id: id));
          } else {
            FlushMessages.commonToast(
              responseData['message'],
              backGroundColor: colorConstants.dimGrayColor,
            );
          }
        } else {
          FlushMessages.commonToast(
            "Something went wrong please try again",
            backGroundColor: colorConstants.dimGrayColor,
          );
          isVerifyCodeLoading = false;
          update();
        }
      } else {
        FlushMessages.commonToast(
          "Something went wrong please try again",
          backGroundColor: colorConstants.dimGrayColor,
        );
        isVerifyCodeLoading = false;
        update();
      }
    } catch (e) {
      FlushMessages.commonToast(
        "$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
      isVerifyCodeLoading = false;
      update();
    } finally {
      isVerifyCodeLoading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                          reset password logic                        */
  /*----------------------------------------------------------------------*/
  void resetPassword(BuildContext context, String? userId) async {
    try {
      if (newPasswordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        FlushMessages.commonToast(
          "Passwords do not match. Please re-enter",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else {
        isResetLoading = true;
        update();
        var response = await AuthenticationService.resetPasswordApi(
          userId,
          confirmPasswordController.text.trim(),
        );
        if (response != null) {
          if (response.statusCode == 200) {
            isResetLoading = false;
            update();
            AuthSuccessDialog.showSuccessDialog(
              context,
              userId: userId,
              password: confirmPasswordController.text.trim(),
              server: "GFCM-Server",
            );
            forgetEmailController.clear();
            codeController.clear();
            newPasswordController.clear();
            confirmPasswordController.clear();
            await Future.delayed(Duration(seconds: 2));
            Get.close(2);
          } else {
            var responseData = jsonDecode(response.body);
            FlushMessages.commonToast(
              responseData['message'],
              backGroundColor: colorConstants.dimGrayColor,
            );
            isResetLoading = false;
            update();
          }
        } else {
          FlushMessages.commonToast(
            "Something went wrong please try again",
            backGroundColor: colorConstants.dimGrayColor,
          );
          isResetLoading = false;
          update();
        }
      }
    } catch (e) {
      FlushMessages.commonToast(
        "$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
      isResetLoading = false;
      update();
    } finally {
      isResetLoading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                              get user details                        */
  /*----------------------------------------------------------------------*/
  Future<void> getUserData() async {
    try {
      profileImage = null;

      isGetUserloading = true;

      update();
      var response = await AuthenticationService.getUserDataApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          userData = responseData['data'];

          await getCountries();
          firstNameController.text = userData?['firstname'];
          lastNameController.text = userData?['lastname'];
          emailController.text = userData?['email'];
          regPasswordController.text = userData?['password'];
          selectedCountry = userData?['country'] ?? "abc";
          selectedCity = userData?['city'];
          countryCode = userData?['countrycode'];
          phoneController.text = userData?['phone'];
          selectedStatus = userData?['type'];
          existingProfileImage = userData?["profile"];
          update();
          await getCities(selectedCountry!);
        } else {
          userData = null;
          update();
        }
      } else {
        userData = null;
        update();
      }
    } catch (e) {
      userData = null;
      update();
    } finally {
      isGetUserloading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                           update user profile                        */
  /*----------------------------------------------------------------------*/
  Future<void> updateUserProfile() async {
    try {
      if (selectedCountry == null) {
        FlushMessages.commonToast(
          "Please select a country",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else if (selectedCity == null) {
        FlushMessages.commonToast(
          "Please select a city",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else if (selectedStatus == null) {
        FlushMessages.commonToast(
          "Please choose a trading type",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else {
        isUpdateUserloading = true;
        update();
        var response = await AuthenticationService.updateUserProfileApi(
          firstNameController.text.trim(),
          lastNameController.text.trim(),
          emailController.text.trim(),
          regPasswordController.text.trim(),
          selectedCountry!,
          selectedCity!,
          countryCode,
          phoneController.text.trim(),
          selectedStatus!,
          existingProfileImage,
          profileImage,
        );
        if (response != null) {
          if (response.statusCode == 200) {
            FlushMessages.commonToast(
              "Profile updated successfully",
              backGroundColor: colorConstants.secondaryColor,
            );
          } else {
            final data = jsonDecode(response.body);
            FlushMessages.commonToast(
              data['message'],
              backGroundColor: colorConstants.dimGrayColor,
            );
          }
        } else {
          FlushMessages.commonToast(
            "Something went wrong please try again",
            backGroundColor: colorConstants.dimGrayColor,
          );
        }
      }
    } catch (e) {
      FlushMessages.commonToast(
        "$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
    } finally {
      isUpdateUserloading = false;
      update();
    }
  }
}
