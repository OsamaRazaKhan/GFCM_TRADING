import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/services/social_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SocialController extends GetxController {
  TextEditingController socialUrlController = TextEditingController();
  List<Map<String, dynamic>?> giveAwayData = [];
  bool isConnectedToInterNet = false;

  bool giveAwayLoader = false;
  ColorConstants colorConstants = ColorConstants();
  final ImagePicker picker = ImagePicker();
  File? giveWayImage;
  File? giveWayVideo;
  bool isRewardloading = false;

  void getGiveAwayDetails() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      isConnectedToInterNet = true;
      update();
    }
    getGiveAways();
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/

  String? socialUrlValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your share URL";
    }
    return null;
  }
  /*----------------------------------------------------------------------*/
  /*                               get give aways                         */
  /*----------------------------------------------------------------------*/

  Future<void> getGiveAways({isFirstOpen = true}) async {
    try {
      giveAwayLoader = true;
      update();
      var response = await SocialServices.getGiveAwayApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          giveAwayData = List<Map<String, dynamic>>.from(
            responseData['Data'] ?? [],
          );

          update();
        } else {
          giveAwayData = [];
          update();
        }
      } else {
        giveAwayData = [];
        update();
      }
    } catch (e) {
      giveAwayData = [];
      update();
    } finally {
      giveAwayLoader = false;
      update();
    }
  }

  /*--------------------------------------------------------------*/
  /*                 select give ways image from gallry           */
  /*--------------------------------------------------------------*/
  Future<void> selectImage() async {
    try {
      giveWayVideo = null;
      update();
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
        giveWayImage = File(pickedFile.path);
        update();
      }
    } catch (e) {
      FlushMessages.commonToast(
        "Failed to pick image. Please try again.",
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*--------------------------------------------------------------*/
  /*                 select give ways video from gallry           */
  /*--------------------------------------------------------------*/
  Future<void> selectVideo() async {
    try {
      giveWayImage = null;
      update();
      if (Platform.isAndroid) {
        // Android 13+ requires `photos` permission
        final photoStatus = await Permission.photos.request();
        if (!photoStatus.isGranted) {
          // Android 12 or below requires `storage`
          final storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            FlushMessages.commonToast(
              "Gallery permission is required to upload videos.",
              backGroundColor: colorConstants.dimGrayColor,
            );
            return;
          }
        }
      }

      final pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // optional
      );

      if (pickedFile != null) {
        giveWayVideo = File(pickedFile.path);
        update();
      }
    } catch (e) {
      FlushMessages.commonToast(
        "Failed to pick video. Please try again.",
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*----------------------------------------------------------------------*/
  /*                            add prof for reward                       */
  /*----------------------------------------------------------------------*/
  Future<void> addRewardProof(String rewardId, String rewardUrl) async {
    try {
      if (giveWayImage == null && giveWayVideo == null) {
        FlushMessages.commonToast(
          "Please must select proof video or image for reward",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else {
        isRewardloading = true;
        update();
        var response = await SocialServices.addRewardProofApi(
          rewardId,
          socialUrlController.text,
          giveWayImage,
          giveWayVideo,
        );

        if (response != null) {
          if (response.statusCode == 200) {
            FlushMessages.commonToast(
              "Proof for reward submitted successfully",
              backGroundColor: colorConstants.secondaryColor,
            );
            giveWayImage = null;
            giveWayVideo = null;
            update();
            getGiveAways();
          } else {
            final responseBody = await response.stream.bytesToString();
            final data = jsonDecode(responseBody);
            FlushMessages.commonToast(
              data['ResponseMsg'],
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
      isRewardloading = false;
      update();
    }
  }
}
