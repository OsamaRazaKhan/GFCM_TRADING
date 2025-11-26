import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/transaction_controller.dart';

import 'package:gfcm_trading/views/custom_widgets/custom_text.dart';
import 'package:gfcm_trading/views/screens/transections_screen.dart/account_transaction.dart';
import 'package:gfcm_trading/views/screens/transections_screen.dart/wallet_trasaction.dart';

class TransectionScreen extends StatefulWidget {
  const TransectionScreen({super.key});

  @override
  State<TransectionScreen> createState() => _TransectionScreenState();
}

class _TransectionScreenState extends State<TransectionScreen> {
  ColorConstants colorConstants = ColorConstants();
  TransactionController transactionController = Get.put(
    TransactionController(),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorConstants.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: colorConstants.blackColor),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen
            },
          ),

          actions: [
            TextButton(
              onPressed: () {},
              child: CustomText(
                "Help",
                size: 18.sp,
                fw: FontWeight.w400,
                color: colorConstants.blueColor,
              ),
            ),

            SizedBox(width: 20.w),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100.h), // increase if needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    "TranSection",
                    size: 20.sp,
                    fw: FontWeight.w500,
                    color: colorConstants.blackColor,
                  ),
                ),
                SizedBox(height: 10.h),
                TabBar(
                  indicatorColor: colorConstants.blackColor,
                  tabs: [
                    Tab(
                      child: FittedBox(
                        child: CustomText(
                          "Wallet Transactions",
                          color: colorConstants.blackColor,
                          size: 12.sp,
                          fw: FontWeight.w500,
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        child: CustomText(
                          "Account Transactions",
                          color: colorConstants.blackColor,
                          size: 12.sp,
                          fw: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(children: [WalletTrasaction(), AccountTransaction()]),
      ),
    );
  }
}
