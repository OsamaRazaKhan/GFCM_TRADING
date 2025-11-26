// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/settings_controller.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? colorConstants.blackColor
                    : colorConstants.blackColor,
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: CustomText(
          "App Settings",
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? colorConstants.blackColor
                  : colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            GetBuilder<SettingsController>(
              init: SettingsController(),
              builder: (settingsController) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText("Themes", size: 14.sp, fw: FontWeight.w700),
                      Transform.scale(
                        scale:
                            0.8, // Adjust the size as needed (e.g., 0.8 for 80% of default size)
                        child: Switch(
                          value: settingsController.isDarkTheme.value,
                          onChanged: (value) {
                            settingsController.setTheme(value);
                          },
                          activeColor:
                              colorConstants
                                  .blueColor, // Thumb color when switch is ON
                          activeTrackColor:
                              Colors.blue[200], // Track color when switch is ON
                          inactiveThumbColor: colorConstants.primaryColor,
                          // Optional: Thumb color when switch is OFF
                          inactiveTrackColor:
                              Colors
                                  .grey[300], // Optional: Track color when switch is OFF
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(
            //       color: colorConstants.dimGrayColor,
            //       width: 0.5,
            //     ),
            //   ),
            // ),
            // Obx(
            //   () => Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 15.w),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         CustomText(
            //           "Enable Hedging",
            //           size: 14.sp,
            //           fw: FontWeight.w700,
            //         ),
            //         Transform.scale(
            //           scale:
            //               0.8, // Adjust the size as needed (e.g., 0.8 for 80% of default size)
            //           child: Switch(
            //             value:
            //                 Get.find<TradeChartController>()
            //                     .selectedModeIsHedge
            //                     .value ==
            //                 "hedgeMode",
            //             onChanged: (val) {
            //               Get.find<TradeChartController>().setHedgeMode(val);
            //             },
            //             activeColor:
            //                 colorConstants
            //                     .blueColor, // Thumb color when switch is ON
            //             activeTrackColor:
            //                 Colors.blue[200], // Track color when switch is ON
            //             inactiveThumbColor: colorConstants.primaryColor,
            //             // Optional: Thumb color when switch is OFF
            //             inactiveTrackColor:
            //                 Colors
            //                     .grey[300], // Optional: Track color when switch is OFF
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
