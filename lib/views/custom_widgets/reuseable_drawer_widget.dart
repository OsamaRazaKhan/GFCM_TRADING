import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/asset_constants.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/nav_controller.dart';
import 'package:gfcm_trading/main.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_image.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_quit_dialog.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/custom_widgets/reuseable_list_tile.dart';
import 'package:gfcm_trading/views/screens/about_screen.dart';
import 'package:gfcm_trading/views/screens/authentication_screens/login_screen.dart';
import 'package:gfcm_trading/views/screens/fund_screens/funds_main_screen.dart';
import 'package:gfcm_trading/views/screens/kyc_screens/kyc_main_screen.dart';
import 'package:gfcm_trading/views/screens/settings_screen.dart';
import 'package:gfcm_trading/views/screens/signals.dart';
import 'package:gfcm_trading/views/screens/social_screen.dart';
import 'package:gfcm_trading/views/screens/termsAndConditions_screen.dart';
import 'package:gfcm_trading/views/screens/transections_screen.dart/transection_screen.dart';
import 'package:gfcm_trading/views/screens/update_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReuseableDrawerWidget extends StatelessWidget {
  const ReuseableDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);
    ColorConstants colorConstants = ColorConstants();
    return Drawer(
      width: mq.width / 1.25,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: colorConstants.primaryColor,
      child: GetBuilder<NavController>(
        init: NavController(),
        builder: (navController) {
          return ListView(
            children: [
              Container(
                padding: EdgeInsets.only(left: 16.w, top: 13.h, bottom: 7.h),
                child: Row(
                  children: [
                    FittedBox(
                      child: CustomImage(
                        image: AssetConstants.gfcmLogo,
                        height: 90.h,
                        width: 90.h,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomText(
                                  "${navController.userData?["firstname"] ?? ""} ${navController.userData?["lastname"] ?? ""}",
                                  size: 16.sp,
                                  fw: FontWeight.w400,
                                  color: colorConstants.blackColor,
                                ),
                              ),
                            ],
                          ),
                          CustomText(
                            "id: ${navController.userData?["id"] ?? ""}",
                            size: 14.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.hintTextColor,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                          CustomText(
                            navController.userData?["profileverification"] ==
                                    "Pending"
                                ? "Unverified"
                                : "Verified",
                            size: 14.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.blueColor,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: colorConstants.hintTextColor),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => FundsMainScreen());
                },
                icon: Transform.scale(
                  scale: 0.7,
                  child: SizedBox(
                    width: 30.sp, // Set your desired compressed width
                    child: Helper.svgIcon(
                      IconConstants.fundsSvg,
                      isSelected: false,
                      isOriginalColor: true,
                      originalColor: colorConstants.blackColor,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                titleText: "Funds",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => KycMainScreen());
                },
                icon: Transform.scale(
                  scale: 0.75.sp,
                  child: Helper.svgIcon(
                    IconConstants.kycSvg,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.blackColor,
                    height: 30,
                    width: 30,
                  ),
                ),
                titleText: "KYC",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => TransectionScreen());
                },
                icon: SizedBox(
                  width: 30, // Set your desired compressed width
                  child: Helper.svgIcon(
                    IconConstants.trasectionSvg,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.blackColor,
                    height: 30,
                    width: 30,
                  ),
                ),
                titleText: "Transactions",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => SocialScreen());
                },
                icon: Transform.scale(
                  scale: 0.8,
                  child: Helper.svgIcon(
                    IconConstants.socialSvg,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.blackColor,
                    height: 30,
                    width: 30,
                  ),
                ),
                titleText: "Social",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
                isTraling: true,
              ),
              ReuseableListTile(
                onTap: () {
                  navController.directToEcnomics();
                },
                icon: Icon(
                  Icons.event_note_outlined,
                  color: colorConstants.blackColor,
                  size: 26.sp,
                  weight: 200,
                ),
                titleText: "Economic Calendar",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => Signals());
                },
                icon: Transform.scale(
                    scale: 0.7,
                    child: Icon(
                      Icons.signal_cellular_alt,
                      size: 30,
                      color: colorConstants.blackColor,
                    )),
                titleText: "Signals",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => UpdateProfileScreen());
                },
                icon: SizedBox(
                  width: 30, // Set your desired compressed width
                  child: Helper.svgIcon(
                    IconConstants.profile,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.blackColor,
                    height: 30,
                    width: 30,
                  ),
                ),
                titleText: "Profile",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              Divider(color: colorConstants.hintTextColor),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => AboutScreen());
                },
                icon: Transform.scale(
                  scale: 0.7,
                  child: Helper.svgIcon(
                    IconConstants.aboutSvg,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.blackColor,
                    height: 30,
                    width: 30,
                  ),
                ),
                titleText: "About",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => TermsAndConditionsScreen());
                },
                icon: Transform.scale(
                  scale: 0.7,
                  child: Helper.svgIcon(
                    IconConstants.aboutSvg,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.blackColor,
                    height: 30,
                    width: 30,
                  ),
                ),
                titleText: "Terms and Conditions",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              ReuseableListTile(
                onTap: () {
                  Get.to(() => SettingsScreen());
                },
                icon: Transform.scale(
                  scale: 0.88,
                  child: SizedBox(
                    width: 29, // Set your desired compressed width
                    child: Helper.svgIcon(
                      IconConstants.settingsSvg,
                      isSelected: false,
                      isOriginalColor: true,
                      originalColor: colorConstants.blackColor,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                titleText: "Settings",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
              ReuseableListTile(
                onTap: () async {
                  CustomDialogs.showQuitDialog(
                    context,
                    height: 230.h,
                    width: 200.w,
                    radius: 5.r,
                    headText: "Logout Confirmation",
                    messageText:
                        "Are you sure you want to log out? You will need to sign in again to access your account.",
                    quitText: "Logout",
                    cancelText: "Cancel",
                    onTap: () async {
                      SharedPreferences sp =
                          await SharedPreferences.getInstance();
                      sp.remove("userId");
                      navController.selectIndex(0);
                      Get.offAll(() => LoginScreen());
                    },
                  );
                },
                icon: Transform.scale(
                  scale: 0.7,
                  child: Helper.svgIcon(
                    IconConstants.logoutSvg,
                    isSelected: false,
                    isOriginalColor: true,
                    originalColor: colorConstants.blackColor,
                    height: 30,
                    width: 30,
                  ),
                ),
                titleText: "Logout",
                titleTextColor: colorConstants.blackColor,
                titleTextFw: FontWeight.w700,
                titleTextSize: 14.sp,
              ),
            ],
          );
        },
      ),
    );
  }
}
