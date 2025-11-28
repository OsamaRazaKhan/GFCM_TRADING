import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/models/signals_model.dart';
import 'package:gfcm_trading/services/trading_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:intl/intl.dart';

class SignalsController extends GetxController {
  List<SignalsModel> signalsList = [];
  bool isSignalsLoading = false;
  Map<int, bool> isSignalsUpdateLoading = {}; // Changed to use signal id as key
  Map<int, String?> pressedButton =
      {}; // Track which button was pressed: "Accepted" or "Rejected" or null
  Map<int, bool> expandedSignals = {}; // Track which signals are expanded

  Timer? _countdownTimer;
  final ColorConstants colorConstants = ColorConstants();

  @override
  void onInit() {
    super.onInit();
    // Start countdown timer
    _startCountdownTimer();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  /*----------------------------------------------------------------------*/
  /*                              get signals                             */
  /*----------------------------------------------------------------------*/

  void getSignals({bool showSignalLoading = true}) async {
    try {
      if (showSignalLoading) {
        isSignalsLoading = true;
      }

      update();

      var response = await TradingServices.getSignalsApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          // Handle flexible response structure
          List<dynamic> data = [];
          if (responseData is List) {
            data = responseData;
          } else if (responseData is Map) {
            data = responseData['data'] as List? ??
                responseData['Data'] as List? ??
                responseData['signals'] as List? ??
                [];
          }

          signalsList = data
              .map((e) {
                try {
                  return SignalsModel.fromJson(e as Map<String, dynamic>);
                } catch (e) {
                  // Skip invalid entries
                  return null;
                }
              })
              .whereType<SignalsModel>()
              .toList();

          update();
        } else {
          signalsList = [];
          update();
        }
      } else {
        signalsList = [];
        update();
      }
    } catch (e) {
      debugPrint("Error fetching signals: $e");
      signalsList = [];
      update();
    } finally {
      isSignalsLoading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                    Check if signal is active                        */
  /*----------------------------------------------------------------------*/

  bool isSignalActive(SignalsModel signal) {
    // Signal is active if status is not "Accepted" or "Rejected" and not expired
    final status = signal.status?.toLowerCase() ?? '';
    final isResponded = status == 'accepted' || status == 'rejected';
    final isExpired = _isExpired(signal);
    return !isResponded && !isExpired;
  }

  /*----------------------------------------------------------------------*/
  /*                    Check if signal is expired                       */
  /*----------------------------------------------------------------------*/

  bool _isExpired(SignalsModel signal) {
    if (signal.validtill == null || signal.validtill!.isEmpty) {
      return false; // If no expiry date, consider it not expired
    }

    try {
      // Try parsing as YYYY-MM-DD format
      final expiryDate = DateFormat('yyyy-MM-dd').parse(signal.validtill!);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expiry =
          DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

      return today.isAfter(expiry);
    } catch (e) {
      // If parsing fails, try other formats
      try {
        final expiryDate = DateTime.parse(signal.validtill!);
        final now = DateTime.now();
        return now.isAfter(expiryDate);
      } catch (e2) {
        return false; // If can't parse, assume not expired
      }
    }
  }

  /*----------------------------------------------------------------------*/
  /*                    Calculate remaining time in seconds               */
  /*----------------------------------------------------------------------*/

  int getRemainingSeconds(SignalsModel signal) {
    if (signal.validtill == null || signal.validtill!.isEmpty) {
      return -1; // No expiry date
    }

    try {
      DateTime expiryDate;

      // Try parsing as YYYY-MM-DD format
      try {
        final parsed = DateFormat('yyyy-MM-dd').parse(signal.validtill!);
        // Set expiry time to end of day (23:59:59)
        expiryDate =
            DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
      } catch (e) {
        // Try parsing as full datetime
        expiryDate = DateTime.parse(signal.validtill!);
      }

      final now = DateTime.now();
      final difference = expiryDate.difference(now).inSeconds;
      return difference;
    } catch (e) {
      return -1; // Error parsing, return -1
    }
  }

  /*----------------------------------------------------------------------*/
  /*                    Start countdown timer                            */
  /*----------------------------------------------------------------------*/

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update UI every second to refresh countdown
      update();
    });
  }

  /*----------------------------------------------------------------------*/
  /*                    Toggle signal expansion                           */
  /*----------------------------------------------------------------------*/

  void toggleSignalExpansion(int signalId) {
    expandedSignals[signalId] = !(expandedSignals[signalId] ?? false);
    update();
  }

  /*----------------------------------------------------------------------*/
  /*                    Update signal status (Accept/Reject)              */
  /*----------------------------------------------------------------------*/

  Future<void> updateSignalStatus(int signalId, String status) async {
    // Validate status
    if (status != "Accepted" && status != "Rejected") {
      FlushMessages.commonToast(
        "Invalid status",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    // Check if signal exists and is active
    final signalIndex = signalsList.indexWhere((s) => s.id == signalId);
    if (signalIndex == -1) {
      FlushMessages.commonToast(
        "Signal not found",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    final signal = signalsList[signalIndex];
    if (!isSignalActive(signal)) {
      FlushMessages.commonToast(
        "Signal is no longer active",
        backGroundColor: colorConstants.dimGrayColor,
      );
      return;
    }

    // CRITICAL: Check if already processing (prevent double-tap)
    if (isSignalsUpdateLoading[signalId] == true) {
      return; // Already processing, ignore
    }

    // Store original status for error rollback
    final originalStatus = signal.status;

    try {
      // CRITICAL: Immediately disable both buttons and mark which button was pressed
      isSignalsUpdateLoading[signalId] = true;
      pressedButton[signalId] = status; // Track which button was pressed
      update(); // Update UI immediately to disable buttons

      var response = await TradingServices.updateSignalsApi(
        signalId: signalId,
        status: status,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          // Update local signal status
          signalsList[signalIndex].status = status;

          // Collapse the expanded signal
          expandedSignals[signalId] = false;

          FlushMessages.commonToast(
            "Signal ${status.toLowerCase()} successfully",
            backGroundColor: colorConstants.secondaryColor,
          );

          // CRITICAL: Update UI immediately to show status change
          update();

          // Refresh signals list to get updated data from server (async, don't block)
          Future.delayed(const Duration(milliseconds: 500), () {
            getSignals();
          });
        } else {
          // CRITICAL: Revert UI on error
          signalsList[signalIndex].status = originalStatus;

          // Try to parse error message
          try {
            final errorData = jsonDecode(response.body);
            final errorMsg = errorData['message'] ??
                errorData['error'] ??
                "Failed to update signal";
            FlushMessages.commonToast(
              errorMsg.toString(),
              backGroundColor: colorConstants.dimGrayColor,
            );
          } catch (e) {
            FlushMessages.commonToast(
              "Failed to update signal",
              backGroundColor: colorConstants.dimGrayColor,
            );
          }
        }
      } else {
        // CRITICAL: Revert UI on no response
        signalsList[signalIndex].status = originalStatus;
        FlushMessages.commonToast(
          "No response from server",
          backGroundColor: colorConstants.dimGrayColor,
        );
      }
    } catch (e) {
      debugPrint("Error updating signal: $e");
      // CRITICAL: Revert UI on exception
      signalsList[signalIndex].status = originalStatus;
      FlushMessages.commonToast(
        "Error updating signal: ${e.toString()}",
        backGroundColor: colorConstants.dimGrayColor,
      );
    } finally {
      // CRITICAL: Clear loading state and pressed button
      isSignalsUpdateLoading[signalId] = false;
      pressedButton[signalId] = null;
      update();
    }
  }
}
