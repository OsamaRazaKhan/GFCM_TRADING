import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/constants/icon_constants.dart';
import 'package:gfcm_trading/controllers/nav_controller.dart';
import 'package:gfcm_trading/utils/helpers/svg_icon_helper.dart';

class bottomNavScreen extends StatefulWidget {
  const bottomNavScreen({super.key});

  @override
  State<bottomNavScreen> createState() => _bottomNavScreenState();
}

class _bottomNavScreenState extends State<bottomNavScreen> {
  ColorConstants colorConstants = ColorConstants();
  NavController navController = Get.put(NavController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    navController.getUserData();
    navController.getDateInRange();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavController>(
      init: NavController(),
      builder: (navController) {
        return WillPopScope(
          onWillPop: () async {
            if (navController.selectedIndex == 0) {
              return true;
            } else {
              navController.selectIndex(0);
              return false;
            }
          },
          child: Scaffold(
            body: navController.pages[navController.selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navController.selectedIndex,
              onTap: (index) {
                if (index != navController.selectedIndex) {
                  navController.selectIndex(index);
                }
              },
              backgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? colorConstants.bottomDarkGrayCol
                      : colorConstants.bottomDarkGrayCol,
              // Background color
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(color: colorConstants.primaryColor),
              selectedFontSize: 12.sp,
              selectedItemColor: colorConstants.secondaryColor,
              unselectedItemColor: colorConstants.hintTextColor,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Helper.svgIcon(
                    IconConstants.dashboardSvg,
                    isSelected: navController.selectedIndex == 0,
                    isOriginalColor: false,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Helper.svgIcon(
                    IconConstants.chartsIcon,
                    isSelected: navController.selectedIndex == 1,
                    isOriginalColor: false,
                  ),
                  label: "Charts",
                ),
                BottomNavigationBarItem(
                  icon: Helper.svgIcon(
                    IconConstants.tradeIcon,
                    isSelected: navController.selectedIndex == 2,
                    isOriginalColor: false,
                  ),
                  label: "Trade",
                ),
                BottomNavigationBarItem(
                  icon: Helper.svgIcon(
                    IconConstants.historyIcon,
                    isSelected: navController.selectedIndex == 3,
                    isOriginalColor: false,
                  ),
                  label: "History",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
