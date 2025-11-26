import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/home_controller.dart';
import 'package:gfcm_trading/utils/helpers/dede_time_helper.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_empty_screen.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  ColorConstants colorConstants = ColorConstants();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorConstants.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorConstants.blackColor),
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        title: CustomText(
          "Notifications",
          color: colorConstants.blackColor,
          fw: FontWeight.w500,
          size: 20.sp,
        ),
        centerTitle: true,
      ),
      body: GetBuilder<HomeController>(
        init: HomeController(), // fetch on init
        builder: (homeController) {
          if (homeController.isNotificationLoading) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorConstants.secondaryColor,
                ),
              ),
            );
          }

          if (homeController.notifications.isEmpty) {
            return Center(
              child: CustomEmptyScreenMessage(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: 80.sp,
                  color: colorConstants.hintTextColor,
                ),
                headText: "No notifications found",

                onTap: () {
                  homeController.getNotifications();
                },
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: homeController.notifications.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final notif = homeController.notifications[index];

              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: colorConstants.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Leading icon (based on type)
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor:
                          notif["status"] == "newnotification"
                              ? colorConstants.redColor.withOpacity(0.2)
                              : colorConstants.blueColor.withOpacity(0.2),
                      child: Icon(
                        Icons.notifications,
                        color:
                            notif["status"] == "newnotification"
                                ? colorConstants.redColor
                                : colorConstants.blueColor,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    //  Message content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            notif["type"].toString().isEmpty
                                ? "General"
                                : notif["type"].toString(),
                            size: 14.sp,
                            fw: FontWeight.w600,
                            color: colorConstants.blackColor,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            notif["message"].toString(),
                            size: 13.sp,
                            fw: FontWeight.w400,
                            color: colorConstants.hintTextColor,
                          ),
                        ],
                      ),
                    ),

                    CustomText(
                      color: colorConstants.hintTextColor,
                      size: 10.sp,
                      fw: FontWeight.w500,
                      DedetimeHelper.dateTimeConverter(
                        notif["datetime"] ?? "2025-08-29T11:03:13.000Z",
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
