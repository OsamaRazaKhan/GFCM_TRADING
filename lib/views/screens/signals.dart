import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/signals_controller.dart';
import 'package:gfcm_trading/models/signals_model.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class Signals extends StatefulWidget {
  const Signals({super.key});

  @override
  State<Signals> createState() => _SignalsState();
}

class _SignalsState extends State<Signals> {
  SignalsController signalsController = Get.put(SignalsController());
  ColorConstants colorConstants = ColorConstants();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    signalsController.getSignals();
    // then call every 7 seconds
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      signalsController.getSignals(showSignalLoading: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // stop timer when screen closes
    super.dispose();
  }

  // Helper method to format countdown timer
  String _formatCountdown(int seconds) {
    if (seconds < 0) return "Expired";
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (days > 0) {
      return "${days}d ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
    } else if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
    } else {
      return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
    }
  }

  // Get full name with fallback
  String _getFullName(SignalsModel signal) {
    final firstName = signal.firstname?.trim() ?? '';
    final lastName = signal.lastname?.trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? "Signal Provider" : fullName;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignalsController>(
      builder: (controller) {
        // Filter active signals (not responded and not expired)
        final activeSignals = controller.signalsList
            .where((s) => controller.isSignalActive(s))
            .toList();
        // Filter responded/expired signals
        final inactiveSignals = controller.signalsList
            .where((s) => !controller.isSignalActive(s))
            .toList();
        // Combine: active first, then inactive
        final allSignals = [...activeSignals, ...inactiveSignals];

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).brightness == Brightness.dark
                    ? colorConstants.blackColor
                    : colorConstants.blackColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: CustomText(
              'Trading Signals',
              color: colorConstants.blackColor,
              fw: FontWeight.w500,
              size: 20.sp,
            ),
            backgroundColor: colorConstants.primaryColor,
            elevation: 0,
            centerTitle: true,
          ),
          body: RefreshIndicator(
            color: colorConstants.secondaryColor,
            onRefresh: () async {
              controller.getSignals();
            },
            child: controller.isSignalsLoading
                ? Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorConstants.secondaryColor,
                      ),
                    ),
                  )
                : allSignals.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(10.r),
                        child: CustomEmptyScreenMessage(
                          icon: Icon(
                            Icons.cloud_off,
                            size: 80.sp,
                            color: colorConstants.hintTextColor,
                          ),
                          headText: "No Signals Found",
                          subtext:
                              "Refresh the page or stay connected to get the latest trading signals.",
                          onTap: () {
                            controller.getSignals();
                          },
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(10.r),
                        itemCount: allSignals.length,
                        itemBuilder: (context, index) {
                          final signal = allSignals[index];
                          final isActive = controller.isSignalActive(signal);
                          final isExpanded =
                              controller.expandedSignals[signal.id] ?? false;
                          final remainingSeconds =
                              controller.getRemainingSeconds(signal);
                          final isExpired = remainingSeconds <= 0;
                          final isLoading =
                              controller.isSignalsUpdateLoading[signal.id] ??
                                  false;
                          final status = signal.status?.toLowerCase() ?? '';

                          return signal.status == "Expired"
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(bottom: 14.h),
                                  decoration: BoxDecoration(
                                    color: isActive && !isExpired
                                        ? colorConstants.primaryColor
                                        : colorConstants.primaryColor
                                            .withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isActive && !isExpired
                                          ? colorConstants.secondaryColor
                                          : colorConstants.iconGrayColor,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Main card content
                                      Padding(
                                        padding: EdgeInsets.all(14.r),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Header row: name + expand button
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: CustomText(
                                                    _getFullName(signal),
                                                    size: 16.sp,
                                                    fw: FontWeight.w600,
                                                    color:
                                                        isActive && !isExpired
                                                            ? colorConstants
                                                                .blackColor
                                                            : colorConstants
                                                                .hintTextColor,
                                                  ),
                                                ),
                                                if (isActive && !isExpired)
                                                  IconButton(
                                                    icon: Icon(
                                                      isExpanded
                                                          ? Icons
                                                              .keyboard_arrow_up
                                                          : Icons
                                                              .keyboard_arrow_down,
                                                      color: colorConstants
                                                          .secondaryColor,
                                                      size: 24.sp,
                                                    ),
                                                    onPressed: () {
                                                      controller
                                                          .toggleSignalExpansion(
                                                              signal.id ?? 0);
                                                    },
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),

                                            // Signal message
                                            CustomText(
                                              signal.message?.trim() ??
                                                  "No message",
                                              size: 14.sp,
                                              color: isActive && !isExpired
                                                  ? colorConstants.blackColor
                                                  : colorConstants
                                                      .hintTextColor,
                                              maxLines: 5,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 10.h),

                                            // Timer and status row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Countdown timer
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      color: isExpired
                                                          ? colorConstants
                                                              .redColor
                                                          : colorConstants
                                                              .secondaryColor,
                                                      size: 16.sp,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    CustomText(
                                                      isExpired
                                                          ? "Expired"
                                                          : _formatCountdown(
                                                              remainingSeconds),
                                                      size: 12.sp,
                                                      fw: FontWeight.w600,
                                                      color: isExpired
                                                          ? colorConstants
                                                              .redColor
                                                          : colorConstants
                                                              .secondaryColor,
                                                    ),
                                                  ],
                                                ),

                                                // Status badge (if responded)
                                                if (status == 'accepted' ||
                                                    status == 'rejected')
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.w,
                                                            vertical: 4.h),
                                                    decoration: BoxDecoration(
                                                      color: status ==
                                                              'accepted'
                                                          ? colorConstants
                                                              .greenColor
                                                              .withOpacity(0.2)
                                                          : colorConstants
                                                              .redColor
                                                              .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.r),
                                                      border: Border.all(
                                                        color:
                                                            status == 'accepted'
                                                                ? colorConstants
                                                                    .greenColor
                                                                : colorConstants
                                                                    .redColor,
                                                      ),
                                                    ),
                                                    child: CustomText(
                                                      signal.status ?? "",
                                                      size: 12.sp,
                                                      fw: FontWeight.w600,
                                                      color:
                                                          status == 'accepted'
                                                              ? colorConstants
                                                                  .greenColor
                                                              : colorConstants
                                                                  .redColor,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Expandable Accept/Reject section
                                      if (isActive && !isExpired && isExpanded)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: colorConstants.fieldColor,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(16.r),
                                              bottomRight:
                                                  Radius.circular(16.r),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(14.r),
                                            child: Row(
                                              children: [
                                                // Accept button
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (isLoading ||
                                                            controller.pressedButton[
                                                                    signal
                                                                        .id] !=
                                                                null)
                                                        ? null
                                                        : () async {
                                                            await controller
                                                                .updateSignalStatus(
                                                              signal.id ?? 0,
                                                              "Accepted",
                                                            );
                                                          },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          controller.pressedButton[
                                                                      signal
                                                                          .id] ==
                                                                  "Accepted"
                                                              ? colorConstants
                                                                  .greenColor
                                                                  .withOpacity(
                                                                      0.7)
                                                              : colorConstants
                                                                  .greenColor,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.h),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.r),
                                                      ),
                                                      elevation:
                                                          controller.pressedButton[
                                                                      signal
                                                                          .id] ==
                                                                  "Accepted"
                                                              ? 2
                                                              : 0,
                                                    ),
                                                    child: (isLoading &&
                                                                controller.pressedButton[
                                                                        signal
                                                                            .id] ==
                                                                    "Accepted") ||
                                                            (controller.isSignalsUpdateLoading[
                                                                        signal
                                                                            .id] ==
                                                                    true &&
                                                                controller.pressedButton[
                                                                        signal
                                                                            .id] ==
                                                                    "Accepted")
                                                        ? SizedBox(
                                                            height: 20.h,
                                                            width: 20.w,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  colorConstants
                                                                      .whiteColor,
                                                            ),
                                                          )
                                                        : CustomText(
                                                            "Accept",
                                                            size: 14.sp,
                                                            fw: FontWeight.w600,
                                                            color:
                                                                colorConstants
                                                                    .whiteColor,
                                                          ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),

                                                // Reject button
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: (isLoading ||
                                                            controller.pressedButton[
                                                                    signal
                                                                        .id] !=
                                                                null)
                                                        ? null
                                                        : () async {
                                                            await controller
                                                                .updateSignalStatus(
                                                              signal.id ?? 0,
                                                              "Rejected",
                                                            );
                                                          },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          controller.pressedButton[
                                                                      signal
                                                                          .id] ==
                                                                  "Rejected"
                                                              ? colorConstants
                                                                  .redColor
                                                                  .withOpacity(
                                                                      0.7)
                                                              : colorConstants
                                                                  .redColor,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.h),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.r),
                                                      ),
                                                      elevation:
                                                          controller.pressedButton[
                                                                      signal
                                                                          .id] ==
                                                                  "Rejected"
                                                              ? 2
                                                              : 0,
                                                    ),
                                                    child: (isLoading &&
                                                                controller.pressedButton[
                                                                        signal
                                                                            .id] ==
                                                                    "Rejected") ||
                                                            (controller.isSignalsUpdateLoading[
                                                                        signal
                                                                            .id] ==
                                                                    true &&
                                                                controller.pressedButton[
                                                                        signal
                                                                            .id] ==
                                                                    "Rejected")
                                                        ? SizedBox(
                                                            height: 20.h,
                                                            width: 20.w,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  colorConstants
                                                                      .whiteColor,
                                                            ),
                                                          )
                                                        : CustomText(
                                                            "Reject",
                                                            size: 14.sp,
                                                            fw: FontWeight.w600,
                                                            color:
                                                                colorConstants
                                                                    .whiteColor,
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                        },
                      ),
          ),
        );
      },
    );
  }
}
