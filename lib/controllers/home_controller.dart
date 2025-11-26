import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/controllers/nav_controller.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/services/authentication_service.dart';
import 'package:gfcm_trading/services/dashboard_services.dart';
import 'package:gfcm_trading/services/trading_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  bool isDemoLoader = false;
  TextEditingController demoAmountController = TextEditingController();
  String? selectedMode = "Real";
  bool isArchive = false;
  bool isDemoBalanceLoader = false;
  String demoOldValue = "0.0";
  bool isNotificationLoading = false;

  double demoBalance = 0.00;

  int notificationCount = 0;
  bool notificationStatus = false;
  List<Map<String, dynamic>> notifications = [];

  double totalProfit = 0.0;
  double totalDeposits = 0.0;
  Map<String, dynamic>? userData;
  double yourTotalCurrent = 0.0;
  double totalConfirmedWithdraws = 0.0;
  void setArchive(bool value) {
    isArchive = value;
    update();
  }

  ColorConstants colorConstants = ColorConstants();

  void selectMode(String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("selectedMode", value);
    selectedMode = value;
    
    // Clear all data and reload for the selected mode
    Get.find<TradeChartController>().loadSelectedMode();
    
    // Clear history data in NavController
    if (Get.isRegistered<NavController>()) {
      final navController = Get.find<NavController>();
      navController.closeTradeList.clear();
      navController.liquitedTradesList.clear();
      navController.commissionsList.clear();
      navController.getPositionsHistoryRecords(); // Reload history for new mode
    }
    
    FlushMessages.commonToast(
      "You have switched to the ${value} account successfully",
      backGroundColor: colorConstants.secondaryColor,
    );
    update();
  }

  void getMode() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    selectedMode = sp.getString("selectedMode") ?? "Real";
    update();
  }

  Future<void> directToEcnomics() async {
    final Uri url = Uri.parse('https://www.investing.com/economic-calendar/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void getHomeScreenData() {
    getMode();
    getNotificationStatus();
    getDemoBalance();
    getProfitLoss();
    getUserData();
    getTotalDeposits();
    getConfirmedWithDraws();
  }

  /*----------------------------------------------------------------------*/
  /*                          get notification status                     */
  /*----------------------------------------------------------------------*/
  void getNotificationStatus() async {
    try {
      var response = await TradingServices.getNotificationStatusApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          notificationCount = responseData["count"];

          getNotifications();

          update();
        } else {
          notificationCount = 0;
          update();
        }
      }
    } catch (e) {
      notificationCount = 0;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                            get notifications                         */
  /*----------------------------------------------------------------------*/

  void getNotifications() async {
    try {
      isNotificationLoading = true;
      update();

      var response = await TradingServices.getNotificationsApi(
        notificationCount,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          notificationStatus = responseData['status'];

          notifications = List<Map<String, dynamic>>.from(
            responseData['data'] ?? [],
          );

          update();
        }
      } else {
        notifications = [];
        update();
      }
    } catch (e) {
      notifications = [];
      update();
    } finally {
      isNotificationLoading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/
  String? userIdValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter user Id";
    }
    return null;
  }

  String? amountValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter enter amount";
    }
    return null;
  }

  /*----------------------------------------------------------------------*/
  /*                       get confirm with draw amount                   */
  /*----------------------------------------------------------------------*/

  Future<void> getConfirmedWithDraws() async {
    try {
      update();
      var response = await TradingServices.getConfirmedWithdrawApi(null, null);
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          
          // Handle different response structures
          double totalAmount = 0.0;
          
          // Helper function to check if withdrawal is confirmed
          bool isConfirmedWithdrawal(Map<String, dynamic> item) {
            final status = (item['status']?.toString() ?? "").toLowerCase();
            final transactionType = (item['transactiontype']?.toString() ?? "").toLowerCase();
            
            // Only count withdrawals that are confirmed/admin approved
            // Status should be "confirmed" (case-insensitive)
            // Transaction type should be "withdraw" (case-insensitive)
            return (status == "confirmed" || status == "approved") && 
                   transactionType == "withdraw";
          }
          
          // Check if response is a list (array of transactions)
          if (responseData is List) {
            // Sum only confirmed withdrawal amounts from the list
            for (var item in responseData) {
              if (item is Map<String, dynamic>) {
                // Only count if status is "Confirmed" and transactiontype is "Withdraw"
                if (isConfirmedWithdrawal(item)) {
                  final amountStr = item['amount']?.toString() ?? "0.0";
                  final amount = double.tryParse(amountStr) ?? 0.0;
                  totalAmount += amount;
                }
              }
            }
          } 
          // Check if response is wrapped in 'data' or 'Data' field
          else if (responseData is Map<String, dynamic>) {
            // First check for TotalAmount field (summary response)
            // If TotalAmount exists, it should already be filtered by the API
            // But we'll still validate it represents confirmed withdrawals
            if (responseData.containsKey('TotalAmount')) {
              String totalWitDraws =
                  (responseData['TotalAmount'] ?? "0.0").toString();
              totalAmount = double.tryParse(totalWitDraws) ?? 0.0;
            }
            // Check if data is wrapped in 'data' or 'Data' field
            else if (responseData.containsKey('data') || responseData.containsKey('Data')) {
              final dataList = responseData['data'] ?? responseData['Data'];
              if (dataList is List) {
                // Sum only confirmed withdrawal amounts from the list
                for (var item in dataList) {
                  if (item is Map<String, dynamic>) {
                    // Only count if status is "Confirmed" and transactiontype is "Withdraw"
                    if (isConfirmedWithdrawal(item)) {
                      final amountStr = item['amount']?.toString() ?? "0.0";
                      final amount = double.tryParse(amountStr) ?? 0.0;
                      totalAmount += amount;
                    }
                  }
                }
              }
            }
            // If it's a single object with 'amount' field
            else if (responseData.containsKey('amount')) {
              // Only count if status is "Confirmed" and transactiontype is "Withdraw"
              if (isConfirmedWithdrawal(responseData)) {
                final amountStr = responseData['amount']?.toString() ?? "0.0";
                totalAmount = double.tryParse(amountStr) ?? 0.0;
              }
            }
          }
          
          totalConfirmedWithdraws = totalAmount;
          update();
        } else {
          // Reset to 0.0 if API returns non-200 status
          totalConfirmedWithdraws = 0.0;
          update();
        }
      } else {
        // Reset to 0.0 if response is null
        totalConfirmedWithdraws = 0.0;
        update();
      }
    } catch (e) {
      // Reset to 0.0 on error and log for debugging
      debugPrint("getConfirmedWithDraws error: $e");
      totalConfirmedWithdraws = 0.0;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                              get demo balance                         */
  /*----------------------------------------------------------------------*/
  Future<void> getDemoBalance({bool isLoading = true}) async {
    try {
      if (isLoading) {
        isDemoBalanceLoader = true;
        update();
      }
      var response = await HomeServices.getDemoBalance();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          String demoBalanceStr = responseData['demobalance'].toString();
          demoBalance = double.tryParse(demoBalanceStr) ?? 0.0;
          demoAmountController.text = demoBalance.toStringAsFixed(2);
          demoOldValue = demoBalance.toStringAsFixed(2);
        }
      }
    } catch (e) {
    } finally {
      isDemoBalanceLoader = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                          update demo balance                         */
  /*----------------------------------------------------------------------*/
  Future<void> updateDemoBalance() async {
    try {
      if (demoOldValue == demoAmountController.text) {
        Get.back();
        // Clear all data and reload for Demo mode
        Get.find<TradeChartController>().loadSelectedMode();
        
        // Clear history data in NavController
        if (Get.isRegistered<NavController>()) {
          final navController = Get.find<NavController>();
          navController.closeTradeList.clear();
          navController.liquitedTradesList.clear();
          navController.commissionsList.clear();
          navController.getPositionsHistoryRecords(); // Reload history for Demo mode
        }
        
        FlushMessages.commonToast(
          "You have switched to the Demo account successfully",
          backGroundColor: colorConstants.secondaryColor,
        );
      } else {
        isDemoLoader = true;
        update();

        var response = await HomeServices.updateDemoBalance(
          demoAmountController.text,
        );

        if (response != null) {
          if (response.statusCode == 200) {
            Get.back();
            await getDemoBalance(isLoading: false);
            
            // Clear all data and reload for Demo mode
            Get.find<TradeChartController>().loadSelectedMode();
            
            // Clear history data in NavController
            if (Get.isRegistered<NavController>()) {
              final navController = Get.find<NavController>();
              navController.closeTradeList.clear();
              navController.liquitedTradesList.clear();
              navController.commissionsList.clear();
              navController.getPositionsHistoryRecords(); // Reload history for Demo mode
            }
            
            FlushMessages.commonToast(
              "You have switched to the Demo account successfully",
              backGroundColor: colorConstants.secondaryColor,
            );
          } else {
            final data = jsonDecode(response.body);
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
      isDemoLoader = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                            get profit & loss                         */
  /*----------------------------------------------------------------------*/

  Future<void> getProfitLoss() async {
    try {
      update();
      var response = await TradingServices.getProfitLossApi(null, null);
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          totalProfit = responseData['NetResult'] ?? 0.0;

          update();
        }
      }
    } catch (e) {}
  }

  /*----------------------------------------------------------------------*/
  /*                              transfer amount                         */
  /*----------------------------------------------------------------------*/
  Future<void> getUserData({isFirstOpen = true}) async {
    try {
      var response = await AuthenticationService.getUserDataApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          userData = responseData['data'];
          yourTotalCurrent =
              double.parse(userData?['partner'].toString() ?? "0.0") +
              double.parse(userData?['social'].toString() ?? "0.0") +
              double.parse(userData?['wallet'].toString() ?? "0.0");
          update();
        }
      }
    } catch (e) {}
  }
  /*----------------------------------------------------------------------*/
  /*                           get deposits total                         */
  /*----------------------------------------------------------------------*/

  Future<void> getTotalDeposits() async {
    try {
      update();
      var response = await TradingServices.getDepositsApi(null, null);
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          totalDeposits = double.parse(
            (responseData?['TotalAmount'] ?? 0).toString(),
          );

          update();
        }
      }
    } catch (e) {}
  }
}
