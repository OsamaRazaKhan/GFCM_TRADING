import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/services/authentication_service.dart';
import 'package:gfcm_trading/services/kyc_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/views/screens/kyc_screens/scan_completed_screen.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class KycControllers extends GetxController with WidgetsBindingObserver {
  ColorConstants colorConstants = ColorConstants();
  File? frontIdImage;
  File? backIdImage;
  File? utilityBillImage;
  final ImagePicker picker = ImagePicker();
  String? verificationStatus;

  late CameraController cameraController;
  late FaceDetector faceDetector;
  File? scannedFaceFile;
  bool isVerificationLoading = false;
  bool isGetUserloading = false;
  String selectedDocType = "ID Card";

  void selectDoctype(String value) {
    selectedDocType = value;
    update();
  }

  /*--------------------------------------------------------------*/
  /*                           get user data                      */
  /*--------------------------------------------------------------*/
  Map<String, dynamic>? userData;
  Future<void> getUserData() async {
    try {
      isGetUserloading = true;
      update();
      var response = await AuthenticationService.getUserDataApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          userData = responseData['data'];
          verificationStatus = userData?["profileverification"];
          update();
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
    } finally {
      isGetUserloading = false;
      update();
    }
  }

  /*--------------------------------------------------------------*/
  /*                  select or capture id card image             */
  /*--------------------------------------------------------------*/
  Future<void> selectOrCaptureImage(bool isGallery, isFront) async {
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
        source: isGallery ? ImageSource.gallery : ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        if (isFront) {
          frontIdImage = File(pickedFile.path);
          update();
        } else {
          backIdImage = File(pickedFile.path);
          update();
        }
      }
    } catch (e) {
      FlushMessages.commonToast(
        "Failed to pick image. Please try again.",
        backGroundColor: colorConstants.dimGrayColor,
      );
    }
  }

  /*--------------------------------------------------------------*/
  /*              select or capture  utility bill image           */
  /*--------------------------------------------------------------*/
  Future<void> selectOrCaptureUtilityBillImage(bool isGallery) async {
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
        source: isGallery ? ImageSource.gallery : ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        utilityBillImage = File(pickedFile.path);
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
  /*                         scan your image                      */
  /*--------------------------------------------------------------*/

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      await _initCamera();
      _initFaceDetector();
    } catch (e) {
      print("Initialization failed: $e");
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      //cameraController?.dispose(); // Dispose previous controller if any

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController.initialize();
      update();
    } catch (e) {
      print("Camera init error: $e");
    }
  }

  void _initFaceDetector() {
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableContours: true, enableLandmarks: true),
    );
  }

  Future<void> captureAndScanFace() async {
    try {
      final XFile file = await cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        scannedFaceFile = File(file.path);
        update();
        Get.to(() => ScanCompletedScreen());
      } else {
        scannedFaceFile = null;
        update();
        debugPrint("No face detected.");
      }
    } catch (e) {
      debugPrint("Error during face scan: $e");
    }
  }

  // 🔁 Handle app lifecycle (pause/resume camera)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(); // re-initialize on resume
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    faceDetector.close();
    super.onClose();
  }

  /*--------------------------------------------------------------*/
  /*                     verify your identity                     */
  /*--------------------------------------------------------------*/
  Future<void> verifyYourIdentity() async {
    try {
      if (frontIdImage == null) {
        FlushMessages.commonToast(
          selectedDocType == "ID Card"
              ? "Please upload the front side of your ID card"
              : selectedDocType == "Passport"
              ? "Please upload a valid passport image"
              : "Please upload a valid license image",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else if (backIdImage == null &&
          (selectedDocType != "Passport" && selectedDocType != "Licence")) {
        FlushMessages.commonToast(
          "Please upload the back side of your ID card.",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else if (scannedFaceFile == null) {
        FlushMessages.commonToast(
          "Please capture a clear photo of your face.",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else if (utilityBillImage == null) {
        FlushMessages.commonToast(
          "Please upload a utility bill for address verification.",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else {
        isVerificationLoading = true;
        update();
        var response = await KycServices.verifyYourIdentityApi(
          selectedDocType,
          frontIdImage!,
          backIdImage,
          scannedFaceFile!,
          utilityBillImage!,
        );

        if (response != null) {
          if (response.statusCode == 200) {
            frontIdImage = null;
            backIdImage = null;
            utilityBillImage = null;
            scannedFaceFile = null;
            selectedDocType = "ID Card";
            FlushMessages.commonToast(
              'Your identity has been recorded successfully',
              backGroundColor: colorConstants.secondaryColor,
            );
            update();
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
      isVerificationLoading = false;
      update();
    }
  }
}
