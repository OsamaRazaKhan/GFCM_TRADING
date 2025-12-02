import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  ColorConstants colorConstants = ColorConstants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorConstants.blackColor),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: CustomText(
          "Terms and conditions",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Logo
                    Center(
                      child: Column(
                        children: [
                          CustomImage(
                            height: 110.h,
                            width: 110.w,
                            image: AssetConstants.gfcmLogo,
                          ),
                          CustomText(
                            "Global Forex Capital Markets",
                            color: colorConstants.blackColor,
                            fw: FontWeight.w600,
                            size: 18.sp,
                          ),
                          SizedBox(height: 10.h),
                          CustomText(
                            "Version 1.0.0",
                            color: colorConstants.dimGrayColor,
                            fw: FontWeight.w600,
                            size: 13.sp,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Description Section
                    CustomText(
                      "GFCM provides a fast, reliable, and secure trading experience for gold trading enthusiasts. "
                      "Stay connected to the market, manage your portfolio, and analyze trends in real time.",
                      color: colorConstants.dimGrayColor,
                      textAlign: TextAlign.justify,
                      size: 14.sp,
                    ),

                    SizedBox(height: 30.h),

                    // Divider
                    Divider(color: colorConstants.grayColor, thickness: 1),

                    SizedBox(height: 10.h),
                    CustomText(
                      "Company Information",
                      color: colorConstants.blackColor,
                      size: 15.sp,
                      fw: FontWeight.w600,
                    ),

                    SizedBox(height: 8.h),
                    CustomText(
                      "Abc Tech.\n123 Business Street, Karachi, Pakistan",
                      color: colorConstants.dimGrayColor,
                      size: 13.sp,
                    ),

                    SizedBox(height: 25.h),
                    Divider(color: colorConstants.grayColor, thickness: 1),

                    // Contact info
                    SizedBox(height: 10.h),

                    CustomText(
                      "Contact Support",
                      color: colorConstants.blackColor,
                      size: 15.sp,
                      fw: FontWeight.w600,
                    ),

                    SizedBox(height: 8.h),

                    CustomText(
                      "Email: support@raccoontech.com\nPhone: +92 300 1234567",
                      color: colorConstants.dimGrayColor,
                      size: 13.sp,
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Center(
              child: CustomText(
                "© 2025 Abc Tech. All rights reserved.",
                color: colorConstants.dimGrayColor,
                size: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
