import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';
import 'package:gfcm_trading/services/fund_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_dropdown_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class DepositController extends GetxController {
  TextEditingController userIdController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String? selectedCurrency;
  bool isDeposit = false;
  final ImagePicker picker = ImagePicker();
  File? depositScreenShot;

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
        depositScreenShot = File(pickedFile.path);
        update();
      }
    } catch (e) {
      FlushMessages.commonToast(
        "Failed to pick image. Please try again.$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*----------------------------------------------------------------------*/
  /*                 select value from search able dropdown               */
  /*----------------------------------------------------------------------*/
  void selectValueFromSearchAbleDropDown(String valueType, String value) {
    if (valueType == 'Currency') {
      selectedCurrency = value;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/

  String? userIdValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter user Id";
    }
    return null;
  }

  String? amountValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter amount";
    }
    double? amount = double.tryParse(value);
    if (amount == null) {
      return "Invalid amount";
    }
    if (amount < 20.0) {
      return "Minimum deposit amount is 20 USD";
    }
    return null; // Return null if validation passes
  }

  /*----------------------------------------------------------------------*/
  /*                             deposit amount                            */
  /*----------------------------------------------------------------------*/
  Future<void> depositYourAmount() async {
    try {
      TransferController transferController;
      if (!Get.isRegistered<TransferController>()) {
        transferController = Get.put(TransferController());
      } else {
        transferController = Get.find<TransferController>();
      }
      if (depositScreenShot != null) {
        isDeposit = true;
        update();
        var response = await fundServices.depositAmount(
          amountController.text,
          depositScreenShot!,
        );
        if (response != null) {
          if (response.statusCode == 201) {
            FlushMessages.commonToast(
              "Amount deposited successfully",
              backGroundColor: colorConstants.secondaryColor,
            );
            transferController.getUserData(isFirstOpen: false);
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
      } else {
        FlushMessages.commonToast(
          "Please upload the deposit screenshot",
          backGroundColor: colorConstants.dimGrayColor,
        );
      }
    } catch (e) {
      FlushMessages.commonToast(
        "$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
    } finally {
      isDeposit = false;
      update();
    }
  }
}



// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gfcm_trading/controllers/transfer_controller.dart';
// import 'package:gfcm_trading/services/fund_services.dart';
// import 'package:gfcm_trading/utils/flush_messages.dart';
// import 'package:gfcm_trading/views/custom_widgets/custom_dropdown_widget.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DepositController extends GetxController {
//   TextEditingController userIdController = TextEditingController();
//   TextEditingController amountController = TextEditingController();
//   String? selectedCurrency;
//   bool isDeposit = false;
//   final ImagePicker picker = ImagePicker();
//   File? depositScreenShot;

//   /*--------------------------------------------------------------*/
//   /*                  select or capture id card image             */
//   /*--------------------------------------------------------------*/
//   Future<void> selectOrCaptureImage() async {
//     try {
//       // Request camera permission
//       if (Platform.isAndroid) {
//         // Try photos permission (Android 13+)
//         final photoStatus = await Permission.photos.request();
//         if (!photoStatus.isGranted) {
//           // Fallback to storage permission (Android 12 or lower)
//           final storageStatus = await Permission.storage.request();
//           if (!storageStatus.isGranted) {
//             FlushMessages.commonToast(
//               "Gallery permission is required to upload images.",
//               backGroundColor: colorConstants.dimGrayColor,
//             );
//             return;
//           }
//         }
//       }

//       final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         preferredCameraDevice: CameraDevice.front,
//       );

//       if (pickedFile != null) {
//         depositScreenShot = File(pickedFile.path);
//         update();
//       }
//     } catch (e) {
//       FlushMessages.commonToast(
//         "Failed to pick image. Please try again.$e",
//         backGroundColor: colorConstants.dimGrayColor,
//       );
//     }
//   }

//   /*----------------------------------------------------------------------*/
//   /*                 select value from search able dropdown               */
//   /*----------------------------------------------------------------------*/
//   void selectValueFromSearchAbleDropDown(String valueType, String value) {
//     if (valueType == 'Currency') {
//       selectedCurrency = value;
//       update();
//     }
//   }

//   /*----------------------------------------------------------------------*/
//   /*                         check and validations                        */
//   /*----------------------------------------------------------------------*/

//   String? userIdValidate(value) {
//     if (value == null || value.trim().isEmpty) {
//       return "Please must enter user Id";
//     }
//     return null;
//   }

//   String? amountValidate(value) {
//     if (value == null || value.trim().isEmpty) {
//       return "Please must enter amount";
//     }
//     return null;
//   }

//   /*----------------------------------------------------------------------*/
//   /*                             deposit amount                            */
//   /*----------------------------------------------------------------------*/
//   Future<void> depositYourAmount() async {
//     try {
//       TransferController transferController;
//       if (!Get.isRegistered<TransferController>()) {
//         transferController = Get.put(TransferController());
//       } else {
//         transferController = Get.find<TransferController>();
//       }
//       if (depositScreenShot != null) {
//         isDeposit = true;
//         update();
//         var response = await fundServices.depositAmount(
//           amountController.text,
//           depositScreenShot!,
//         );
//         if (response != null) {
//           if (response.statusCode == 201) {
//             FlushMessages.commonToast(
//               "Amount deposited successfully",
//               backGroundColor: colorConstants.secondaryColor,
//             );
//             transferController.getUserData(isFirstOpen: false);
//             Get.back();
//           } else {
//             final responseBody = await response.stream.bytesToString();
//             final data = jsonDecode(responseBody);
//             FlushMessages.commonToast(
//               data['message'],
//               backGroundColor: colorConstants.dimGrayColor,
//             );
//           }
//         } else {
//           FlushMessages.commonToast(
//             "Something went wrong please try again",
//             backGroundColor: colorConstants.dimGrayColor,
//           );
//         }
//       } else {
//         FlushMessages.commonToast(
//           "Please upload the deposit screenshot",
//           backGroundColor: colorConstants.dimGrayColor,
//         );
//       }
//     } catch (e) {
//       FlushMessages.commonToast(
//         "$e",
//         backGroundColor: colorConstants.dimGrayColor,
//       );
//     } finally {
//       isDeposit = false;
//       update();
//     }
//   }
// }
