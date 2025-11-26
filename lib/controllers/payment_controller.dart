import 'dart:async';
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

class PaymentController extends GetxController {
  ColorConstants colorConstants = ColorConstants();
  TextEditingController cnicController = TextEditingController();
  File? frontIdImage;
  File? backIdImage;
  File? selfieImage;
  final ImagePicker picker = ImagePicker();
  String selectedPaymentMethod = "Flat";
  bool isPaymentUpdate = false;
  /*----------------------------------------------------------*/
  /*                   Select payment method                  */
  /*----------------------------------------------------------*/
  void selectPaymentmethod(String value) {
    selectedPaymentMethod = value;
    update();
  }

  /*--------------------------------------------------------------*/
  /*                  select or capture id card image             */
  /*--------------------------------------------------------------*/
  Future<void> selectOrCaptureImage(bool isSelfie, bool isFront) async {
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

      // Pick image from front camera
      final pickedFile = await picker.pickImage(
        source: isSelfie ? ImageSource.camera : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        if (isSelfie) {
          selfieImage = File(pickedFile.path);
          update();
        } else {
          if (isFront) {
            frontIdImage = File(pickedFile.path);
            update();
          } else {
            backIdImage = File(pickedFile.path);
            update();
          }
        }
      }
    } catch (e) {
      FlushMessages.commonToast(
        "Failed to pick image. Please try again.",
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/

  String? cnicValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter your CNIC";
    }
    return null;
  }

  /*----------------------------------------------------------------------*/
  /*                        update your payment method                    */
  /*----------------------------------------------------------------------*/

  Future<void> updateYourPaymentMethod(String id, String userId) async {
    try {
      isPaymentUpdate = true;
      update();

      final response = await fundServices.updatePaymentMethodApi(id, userId);
      if (response != null) {
        if (response.statusCode == 200) {
          FlushMessages.commonToast(
            "Payment method updated successfully",
            backGroundColor: colorConstants.secondaryColor,
          );
          Get.put(TransferController()).getYourPaymentMethods();
          Get.back();
        } else {
          final data = jsonDecode(response.body);
          FlushMessages.commonToast(
            data['message'],
            backGroundColor: colorConstants.dimGrayColor,
          );
          Get.back();
        }
      } else {
        FlushMessages.commonToast(
          "Something went wrong please try again",
          backGroundColor: colorConstants.dimGrayColor,
        );
      }
    } catch (e) {
    } finally {
      isPaymentUpdate = false;
      update();
    }
  }
}
