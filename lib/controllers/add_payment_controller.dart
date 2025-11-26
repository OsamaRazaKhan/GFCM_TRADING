import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';
import 'package:gfcm_trading/services/fund_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPaymentController extends GetxController {
  ColorConstants colorConstants = ColorConstants();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController swiftNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String? selectedPaymentType;
  File? walletScreenShot;
  final ImagePicker picker = ImagePicker();
  String selectedPaymentMethod = "Crypto";
  String selectedPaymentScreen = "Currency Type";
  bool isPaymentSubmitLoading = false;
  List<String> paymentTypesList = [];
  Set<String> uniqueTypes = {};
  bool isTypeLoading = false;

  /*--------------------------------------------------------------*/
  /*                  select or capture id card image             */
  /*--------------------------------------------------------------*/

  Future<void> selectOrCaptureImage() async {
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
        walletScreenShot = File(pickedFile.path);
        update();
      }
    } catch (e) {
      FlushMessages.commonToast(
        "Failed to pick image. Please try again.",
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*----------------------------------------------------------*/
  /*                   Select payment method                  */
  /*----------------------------------------------------------*/
  void selectPaymentmethod(String value) {
    selectedPaymentMethod = value;
    update();
  }

  /*----------------------------------------------------------*/
  /*                   Select payment method                  */
  /*----------------------------------------------------------*/
  void selectType(String value) {
    selectedPaymentScreen = value;
    update();
  }

  /*----------------------------------------------------------------------*/
  /*                 select value from search able dropdown               */
  /*----------------------------------------------------------------------*/
  void selectValueFromSearchAbleDropDown(String valueType, String value) {
    if (valueType == 'Type') {
      selectedPaymentType = value;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/

  String? bankNameValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter bank name";
    }
    return null;
  }

  String? accountNameValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter enter account name";
    }
    return null;
  }

  String? accountNumberValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter account number";
    }
    return null;
  }

  String? swiftNameValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter swift number";
    }
    return null;
  }

  String? addressValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter your address";
    }
    return null;
  }

  /*--------------------------------------------------------------*/
  /*                         add your payment                     */
  /*--------------------------------------------------------------*/
  Future<void> addPaymentMethod() async {
    try {
      if (selectedPaymentType == null) {
        FlushMessages.commonToast(
          "Please select a payment type",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else if (walletScreenShot == null) {
        FlushMessages.commonToast(
          "Please upload a wallet screenshot",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else {
        isPaymentSubmitLoading = true;
        update();
        var response = await fundServices.addPaymentApi(
          selectedPaymentMethod,
          selectedPaymentType!,
          bankNameController.text.trim(),
          accountNameController.text.trim(),
          accountNumberController.text.trim(),
          swiftNumberController.text.trim(),
          addressController.text.trim(),
          walletScreenShot!,
        );
        if (response != null) {
          if (response.statusCode == 201) {
            FlushMessages.commonToast(
              'Your payment method has been added successfully',
              backGroundColor: colorConstants.secondaryColor,
            );
            selectedPaymentType = null;
            bankNameController.clear();
            accountNameController.clear();
            accountNumberController.clear();
            swiftNumberController.clear();
            addressController.clear();
            walletScreenShot = null;
            update();
            Get.put(TransferController()).getYourPaymentMethods();
            Get.back();
          } else {
            final responseBody = await response.stream.bytesToString();
            final data = jsonDecode(responseBody);
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
      isPaymentSubmitLoading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                        get payment method types                      */
  /*----------------------------------------------------------------------*/
  Future<void> getPaymentTypes() async {
    try {
      isTypeLoading = true;
      paymentTypesList.clear();
      uniqueTypes.clear();
      update();
      var response = await fundServices.getPaymentTypes();
      if (response != null) {
        if (response.statusCode == 200) {
          isTypeLoading = false;
          update();
          var responseData = jsonDecode(response.body);

          for (int i = 0; i < responseData.length; i++) {
            final name = responseData[i]['type'];
            if (name != null && uniqueTypes.add(name)) {
              paymentTypesList.add(name);
            }
          }
          update();
        } else {
          paymentTypesList.clear();
          uniqueTypes.clear();

          update();
        }
      } else {
        paymentTypesList.clear();
        uniqueTypes.clear();

        update();
      }
    } catch (e) {
      paymentTypesList.clear();
      uniqueTypes.clear();

      update();
    } finally {
      isTypeLoading = false;
      update();
    }
  }
}
