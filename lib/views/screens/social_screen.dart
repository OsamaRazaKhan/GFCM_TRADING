import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/social_controller.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_button.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  ColorConstants colorConstants = ColorConstants();
  SocialController socialController = Get.put(SocialController());
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socialController.getGiveAwayDetails();
  }

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
          "Social",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),

      body: GetBuilder<SocialController>(
        init: SocialController(),
        builder: (socialController) {
          return socialController.giveAwayLoader
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorConstants.secondaryColor,
                    ),
                  ),
                ),
              )
              : socialController.giveAwayData.isEmpty
              ? Container(
                padding: EdgeInsets.all(10.r),
                child: CustomEmptyScreenMessage(
                  icon: Icon(
                    socialController.isConnectedToInterNet
                        ? Icons
                            .check_circle_outline //  already shared
                        : Icons.cloud_off, //  no posts yet
                    size: 80.sp,
                    color: colorConstants.hintTextColor,
                  ),
                  headText:
                      socialController.isConnectedToInterNet
                          ? "You’ve Already Shared!"
                          : "No Posts Available",
                  subtext:
                      socialController.isConnectedToInterNet
                          ? "You already shared your post — thank you for participating!\nStay tuned, we’ll announce new rewards soon."
                          : "Something went wrong or no posts are available right now.\nPlease refresh your feed",
                  onTap: () {
                    socialController.getGiveAways();
                  },
                ),
              )
              : Form(
                key: formKey,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount:
                      socialController
                          .giveAwayData
                          .length, // replace with API data length
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: colorConstants.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(5, 5), // Right and bottom shadow
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),

                      margin: EdgeInsets.only(
                        left: 5.w,
                        right: 5.w,
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  "Gold Market Update – XAUUSDT",
                                  fw: FontWeight.w700,
                                  size: 14.sp,
                                ),
                                SizedBox(height: 6.h),
                                CustomText(
                                  socialController
                                          .giveAwayData[index]?["instructions"] ??
                                      "",
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                  size: 12,
                                  fw: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),

                          // Action buttons (points, comments, share)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.emoji_events_outlined),
                                    SizedBox(width: 5.w),
                                    CustomText(
                                      socialController
                                              .giveAwayData[index]?["reward"] ??
                                          "0",
                                      fw: FontWeight.w500,
                                      size: 12.sp,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share_outlined),
                                  onPressed: () async {
                                    var postUrl =
                                        socialController
                                            .giveAwayData[index]?["link"];
                                    if (postUrl != null && postUrl.isNotEmpty) {
                                      // Append a random query to force fresh open every time
                                      postUrl =
                                          "$postUrl?refresh=${DateTime.now().millisecondsSinceEpoch}";

                                      final Uri fbPostUri = Uri.parse(postUrl);

                                      try {
                                        if (await canLaunchUrl(fbPostUri)) {
                                          await launchUrl(
                                            fbPostUri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } else {
                                          FlushMessages.commonToast(
                                            "Could not open the Facebook post.",
                                            backGroundColor:
                                                colorConstants.dimGrayColor,
                                          );
                                        }
                                      } catch (e) {}
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          const Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.sp),
                            child: CustomText(
                              "Submit proof to unlock your reward",
                              fw: FontWeight.w400,
                              size: 14.sp,
                            ),
                          ),

                          SizedBox(height: 5.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: CustomTextFormField(
                              borderColor: colorConstants.fieldBorderColor,
                              hintText: "https://example.com",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                color: colorConstants.hintTextColor,
                              ),
                              fillColor: colorConstants.fieldColor,
                              validateFunction:
                                  socialController.socialUrlValidate,
                              controller: socialController.socialUrlController,
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: CustomButton(
                                  height: 41.h,
                                  width: 140.w,
                                  bordercircular: 12.r,
                                  borderColor: colorConstants.primaryColor,
                                  borderWidth: 2.sp,
                                  text: "Add Proof",
                                  textColor: colorConstants.primaryColor,

                                  boxColor: colorConstants.secondaryColor,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  Icons.image,
                                                  color:
                                                      colorConstants.blueColor,
                                                ),
                                                title: CustomText(
                                                  "Upload Image",
                                                  size: 12.sp,
                                                ),
                                                onTap: () {
                                                  socialController
                                                      .selectImage();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(
                                                  Icons.videocam,
                                                  color:
                                                      colorConstants.redColor,
                                                ),
                                                title: CustomText(
                                                  "Upload Video",
                                                  size: 12.sp,
                                                ),
                                                onTap: () {
                                                  socialController
                                                      .selectVideo();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },

                                  icon: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: colorConstants.whiteColor,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: CustomButton(
                                  height: 41.h,
                                  width: 140.w,
                                  bordercircular: 12.r,
                                  borderColor: colorConstants.primaryColor,
                                  borderWidth: 2.sp,
                                  text: "Submit",
                                  textColor: colorConstants.primaryColor,

                                  boxColor: colorConstants.secondaryColor,
                                  onTap:
                                      socialController.isRewardloading
                                          ? null
                                          : () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              socialController.addRewardProof(
                                                socialController
                                                        .giveAwayData[index]?["id"]
                                                        .toString() ??
                                                    "0",
                                                socialController
                                                        .giveAwayData[index]?["link"] ??
                                                    "",
                                              );
                                            }
                                          },
                                  loader: socialController.isRewardloading,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 10.w,
                              right: 10.w,
                              bottom: 10.h,
                            ),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(
                                0.1,
                              ), // transparent red background
                              border: Border.all(
                                color: colorConstants.redColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomText(
                              "If we detect fraud, violent activity, or other prohibited behavior, "
                              "your account will be suspended and your email address may be added "
                              "to our internal blacklist.",
                              color: colorConstants.redColor,
                              size: 12.sp,
                              fw: FontWeight.w500,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
        },
      ),
    );
  }
}
