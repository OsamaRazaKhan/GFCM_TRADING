import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/color_constants.dart';
import 'package:gfcm_trading/models/close_trades_model.dart';
import 'package:gfcm_trading/models/commission_model.dart';
import 'package:gfcm_trading/models/liquited_trades_model.dart';
import 'package:gfcm_trading/services/authentication_service.dart';
import 'package:gfcm_trading/services/dashboard_services.dart';
import 'package:gfcm_trading/services/referal_services.dart';
import 'package:gfcm_trading/services/trading_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';

import 'package:gfcm_trading/views/screens/chart_screen.dart';
import 'package:gfcm_trading/views/screens/dash_board/home_screen.dart';
import 'package:gfcm_trading/views/screens/history_screens.dart/history_main_screen.dart';

import 'package:gfcm_trading/views/screens/trade_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NavController extends GetxController {
  List<CloseTradesModel> closeTradeList = <CloseTradesModel>[];
  List<LiquitedTradesModel> liquitedTradesList = <LiquitedTradesModel>[];
  List<CommissionDetailModel> commissionsList = <CommissionDetailModel>[];
  ColorConstants colorConstants = ColorConstants();
  int selectedIndex = 0;
  String? dateValue;
  bool isGetUserloading = false;
  Map<String, dynamic>? userData;
  double yourBalance = 0.0;
  double yourCredit = 0.0;
  double totalProfit = 0.0;
  double totalDeposits = 0.0;
  double partnerBalance = 0.0;
  Map<String, bool> isSubmitMap = {};

  double demoBalance = 0.0;
  double totalConfirmedWithdraws = 0.0;
  String? toDayDate;
  String? lastWeekDate;
  String? lastMonthDate;
  String? lastThreeMonthsDate;
  int totalCommission = 0;
  bool isUpdateReferralBalance = true;
  String? selectedPeriod;

  String? fromDate;
  String? toDate;
  String? lastWeek;
  String? lastMonth;
  String? lastThreemonths;
  String? selectedMode;
  String type = "tradePositions";

  static final DateFormat formatter = DateFormat('yyyy-MM-dd');

  void clearPositionsDate() {
    fromDate = null;
    toDate = null;
    selectedPeriod = null;
    type = "tradePositions";
    update();
  }

  void clearLiquitedTradesDate() {
    fromDate = null;
    toDate = null;
    selectedPeriod = null;
    type = "liquitedTrades";
    update();
  }

  void clearCommisionsDate() {
    fromDate = null;
    toDate = null;
    selectedPeriod = null;
    type = "commissionsHistory";
    update();
  }

  Future<void> directToEcnomics() async {
    final Uri url = Uri.parse('https://www.investing.com/economic-calendar/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  List<Widget> get pages {
    return [
      HomeScreen(),
      ChartsScreen(),
      const TradeScreen(),
      const HistoryMainScreen(),
    ];
  }

  /*--------------------------------------------------------------------------*/
  /*                                 date selector                            */
  /*--------------------------------------------------------------------------*/

  Future<void> selectDate(BuildContext context) async {
    // Use current date range if available, otherwise use today
    DateTimeRange? initialRange;
    if (fromDate != null && toDate != null) {
      try {
        initialRange = DateTimeRange(
          start: formatter.parse(fromDate!),
          end: formatter.parse(toDate!),
        );
      } catch (e) {
        initialRange = DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(Duration(days: 7)),
        );
      }
    } else {
      initialRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 7)),
      );
    }

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1910),
      lastDate: DateTime(2201),
      initialDateRange: initialRange,
    );

    if (picked != null) {
      DateTime selectFromDate = picked.start;
      DateTime selectToDate = picked.end;

      // If user selects same day for both -> treat as single date
      if (selectFromDate == selectToDate) {
        fromDate = DateFormat('yyyy-MM-dd').format(selectFromDate);
        toDate = fromDate; // same date
      } else {
        fromDate = DateFormat('yyyy-MM-dd').format(selectFromDate);
        toDate = DateFormat('yyyy-MM-dd').format(selectToDate);
      }
      
      // Set selected period to "Custom period" for UI consistency
      selectedPeriod = "Custom period";
      
      // Refresh data based on current type
      if (type == "liquitedTrades") {
        getYourLiquitedHistory();
      }
      if (type == "tradePositions") {
        getPositionsHistoryRecords();
      }
      if (type == "commissionsHistory") {
        getCommissionsHistory();
      }
      update();
    }
  }

  /*--------------------------------------------------------------------------*/
  /*                      get history in specific date range                  */
  /*--------------------------------------------------------------------------*/
  void selectDatePeriod(String value) {
    // Always update date ranges to ensure they're current
    getDateInRange();
    selectedPeriod = value;
    
    if (value == "Today") {
      fromDate = toDayDate;
      toDate = toDayDate;
    } else if (value == "Last week") {
      fromDate = lastWeek;
      toDate = toDayDate;
    } else if (value == "Last month") {
      fromDate = lastMonth;
      toDate = toDayDate;
    } else if (value == "Last 3 months") {
      fromDate = lastThreemonths;
      toDate = toDayDate;
    } else if (value == "Custom period") {
      // Custom period dates are set in selectDate(), just update UI
      // Don't clear dates here
    }
    
    // Refresh data based on current type
    if (type == "liquitedTrades") {
      getYourLiquitedHistory();
    } else if (type == "tradePositions") {
      getPositionsHistoryRecords();
    } else if (type == "commissionsHistory") {
      getCommissionsHistory();
    }
    
    update();
  }

  void getPositionsHistoryRecords() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    selectedMode = sp.getString("selectedMode") ?? "Real";
    update();
    if (selectedMode == "Real") {
      // Fetch all data in parallel for better performance
      getYourTradsHistory();
      getUserData();
      getProfitLoss();
      getTotalDeposits();
      getConfirmedWithDraws(); // This will filter by date and show only confirmed withdrawals
      getYourCredits();
      getTotalCommission();
    } else {
      totalConfirmedWithdraws = 0.0;
      totalDeposits = 0.0;
      getYourTradsHistory();
      getDemoBalance();
      getProfitLoss();
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         get credits with filter                       */
  /*----------------------------------------------------------------------*/

  Future<void> getYourCredits() async {
    try {
      if (fromDate != null && toDate != null) {
        update();
        var response = await TradingServices.getYourCreditApi(
          fromDate!,
          toDate!,
        );
        if (response != null) {
          if (response.statusCode == 200) {
            var responseData = jsonDecode(response.body);

            yourCredit = double.parse(
              (responseData?["totalAmount"] == ""
                      ? "0.0"
                      : responseData?["totalAmount"] ?? 0.0)
                  .toString(),
            );

            update();
          } else {
            yourCredit = 0.0;
            update();
          }
        } else {
          yourCredit = 0.0;
          update();
        }
      } else {
        // When dates are cleared, reset to user's total credit from userData
        // This will be set in getUserData() if fromDate and toDate are null
        if (userData != null) {
          yourCredit = double.parse(
            (userData?["comission"] == ""
                    ? "0.0"
                    : userData?["comission"] ?? 0.0)
                .toString(),
          );
        } else {
          yourCredit = 0.0;
        }
        update();
      }
    } catch (e) {
      yourCredit = 0.0;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                           get total commission                       */
  /*----------------------------------------------------------------------*/

  Future<void> getTotalCommission() async {
    if (fromDate == null && toDate == null) {
      try {
        var response = await ReferalServices.getYourReferralsApi(
          1,
          0,
          null,
          null,
          null,
          null,
        );

        if (response != null) {
          if (response.statusCode == 200) {
            var responseData = jsonDecode(response.body);

            totalCommission = responseData['totalReferralAmount'];
            update();
          } else {
            totalCommission = 0;
            update();
          }
        } else {
          totalCommission = 0;
          update();
        }
      } catch (e) {
        totalCommission = 0;
        update();
      }
    }
  }

  /*----------------------------------------------------------------------*/
  /*                              get demo balance                         */
  /*----------------------------------------------------------------------*/

  Future<void> getDemoBalance() async {
    try {
      update();
      var response = await HomeServices.getDemoBalance();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          demoBalance = double.parse(responseData['demobalance']);
        }
      }
    } catch (e) {}
  }

  /*------------------------------------------------------*/
  /*               get trade positions history            */
  /*------------------------------------------------------*/

  // inside your HistoryController
  int positionsLimit = 20; // fixed chunk size
  int positionsOffset = 0; // start at 0
  bool isLoadingMore = false;
  bool hasPositionsMoreData = true;

  // Helper function to parse dateTime string to DateTime for sorting
  DateTime? _parseDateTime(String dateStr) {
    if (dateStr.isEmpty) return null;
    
    try {
      // Try parsing as ISO format first (most common from APIs)
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        // Try parsing as "dd/MM/yyyy" format
        return DateFormat('dd/MM/yyyy').parse(dateStr);
      } catch (_) {
        try {
          // Try parsing as "yyyy-MM-dd" format
          return DateFormat('yyyy-MM-dd').parse(dateStr);
        } catch (_) {
          try {
            // Try parsing as "dd-MM-yyyy" format
            return DateFormat('dd-MM-yyyy').parse(dateStr);
          } catch (_) {
            return null;
          }
        }
      }
    }
  }

  // Helper function to sort trades by dateTime (newest first)
  void _sortTradesByDate(List<CloseTradesModel> trades) {
    trades.sort((a, b) {
      final dateA = _parseDateTime(a.dateTime);
      final dateB = _parseDateTime(b.dateTime);
      
      if (dateA == null && dateB == null) {
        // Both null, compare as strings (descending)
        return b.dateTime.compareTo(a.dateTime);
      } else if (dateA == null) {
        return 1; // null dates go to end
      } else if (dateB == null) {
        return -1; // null dates go to end
      } else {
        // Sort descending (newest first)
        return dateB.compareTo(dateA);
      }
    });
  }

  Future<void> getYourTradsHistory({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore || !hasPositionsMoreData) return;
      isLoadingMore = true;
      positionsOffset += positionsLimit; // move offset forward
    } else {
      positionsOffset = 0; // reset
      closeTradeList.clear();
      hasPositionsMoreData = true;
    }

    try {
      update();
      var response = await TradingServices.getTradesHistory(
        positionsLimit,
        positionsOffset,
        fromDate,
        toDate,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // handle response being list OR wrapped object with Data / data
        final List<dynamic> tradesJson;
        if (data is List) {
          tradesJson = data;
        } else {
          tradesJson = (data['Data'] ?? data['data'] ?? []) as List<dynamic>;
        }

        final List<CloseTradesModel> newTrades =
            tradesJson
                .map(
                  (x) => CloseTradesModel.fromJson(x as Map<String, dynamic>),
                )
                .toList();

        // Sort by dateTime in descending order (newest first)
        _sortTradesByDate(newTrades);

        //  Instead of deduplication by key, just append
        if (loadMore) {
          closeTradeList.addAll(newTrades);
          // Re-sort the entire list after adding more items to maintain newest-first order
          _sortTradesByDate(closeTradeList);
        } else {
          closeTradeList = newTrades;
        }

        // check if more data exists
        hasPositionsMoreData = newTrades.length == positionsLimit;
      } else {
        hasPositionsMoreData = false;
      }
    } catch (e, st) {
      debugPrint("getYourTradsHistory error: $e\n$st");
      hasPositionsMoreData = false;
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  // /*-------------------------------------------------------*/
  // /*                 get liquited trades history           */
  // /*-------------------------------------------------------*/
  // //inside your HistoryController
  int liquitedLimit = 10; // fixed chunk size
  int liquitedOffset = 0; // start at 0
  bool isLiquitedLoadingMore = false;
  bool hasLiquitedMoreData = true;

  Future<void> getYourLiquitedHistory({bool loadMore = false}) async {
    if (loadMore) {
      if (isLiquitedLoadingMore || !hasLiquitedMoreData) return;
      isLiquitedLoadingMore = true;
      liquitedOffset += liquitedLimit; // move offset forward
    } else {
      liquitedOffset = 0; // reset
      liquitedTradesList.clear();
      hasLiquitedMoreData = true;
    }

    try {
      update();
      var response = await TradingServices.getLiquitedTradesHistory(
        liquitedLimit,
        liquitedOffset,
        fromDate,
        toDate,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // handle response being list OR wrapped object with Data / data
        final List<dynamic> tradesJson;
        if (data is List) {
          tradesJson = data;
        } else {
          tradesJson = (data['Data'] ?? data['data'] ?? []) as List<dynamic>;
        }

        final List<LiquitedTradesModel> newLiquitedTrades =
            tradesJson
                .map(
                  (x) =>
                      LiquitedTradesModel.fromJson(x as Map<String, dynamic>),
                )
                .toList();

        //  Instead of deduplication by key, just append
        if (loadMore) {
          liquitedTradesList.addAll(newLiquitedTrades);
        } else {
          liquitedTradesList = newLiquitedTrades;
        }

        // check if more data exists
        hasLiquitedMoreData = newLiquitedTrades.length == liquitedLimit;
        isLiquitedLoadingMore = false;
        update();
      } else {
        hasLiquitedMoreData = false;
      }
    } catch (e, st) {
      debugPrint("getYourTradsHistory error: $e\n$st");
      hasLiquitedMoreData = false;
    } finally {
      isLiquitedLoadingMore = false;
      update();
    }
  }

  /*-------------------------------------------------------*/
  /*             submit commission confirmation            */
  /*-------------------------------------------------------*/

  Future<void> updateReferralBalance(
    String commissionAmount,
    String controllerId,
    int id,
  ) async {
    try {
      isSubmitMap[controllerId] = true;
      update([controllerId]);
      var response = await TradingServices.updateReferralBalanceApi(
        commissionAmount,
        partnerBalance,
        id,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          FlushMessages.commonToast(
            "Your request has been submitted successfully",
            backGroundColor: colorConstants.secondaryColor,
          );
          getCommissionsHistory();
        } else {
          FlushMessages.commonToast(
            "Something went wrong please try again",
            backGroundColor: colorConstants.dimGrayColor,
          );
        }
      } else {
        FlushMessages.commonToast(
          "Something went wrong please try again",
          backGroundColor: colorConstants.dimGrayColor,
        );
      }
    } catch (e) {
    } finally {
      isSubmitMap[controllerId] = false;
      update([controllerId]);
    }
  }

  /*-------------------------------------------------------*/
  /*                   get Commissions history             */
  /*-------------------------------------------------------*/

  int commissionLimit = 10; // fixed chunk size
  int commissionOffset = 0; // start at 0
  bool iCommissionLoadingMore = false;
  bool hasCommissionMoreData = true;

  Future<void> getCommissionsHistory({bool loadMore = false}) async {
    update();
    if (loadMore) {
      if (iCommissionLoadingMore || !hasCommissionMoreData) return;

      iCommissionLoadingMore = true;

      commissionOffset += commissionLimit; // move offset forward
    } else {
      commissionOffset = 0; // reset
      commissionsList.clear();
      hasCommissionMoreData = true;
    }

    try {
      update();
      var response = await TradingServices.getCommissionsHistory(
        commissionLimit,
        commissionOffset,
        fromDate,
        toDate,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // handle response being list OR wrapped object with Data / data
        final List<dynamic> tradesJson;
        if (data is List) {
          tradesJson = data;
        } else {
          tradesJson = (data['data'] ?? data['data'] ?? []) as List<dynamic>;
        }

        final List<CommissionDetailModel> newLiquitedTrades =
            tradesJson
                .map(
                  (x) =>
                      CommissionDetailModel.fromJson(x as Map<String, dynamic>),
                )
                .toList();

        //  Instead of deduplication by key, just append
        if (loadMore) {
          commissionsList.addAll(newLiquitedTrades);
        } else {
          commissionsList = newLiquitedTrades;
        }

        // check if more data exists
        hasCommissionMoreData = newLiquitedTrades.length == commissionLimit;
        iCommissionLoadingMore = false;
        update();
      } else {
        hasCommissionMoreData = false;
      }
    } catch (e, st) {
      debugPrint("getYourTradsHistory error: $e\n$st");
      hasCommissionMoreData = false;
    } finally {
      iCommissionLoadingMore = false;
      update();
    }
  }

  /*--------------------------------------------------------------------------*/
  /*                             get date in range                            */
  /*--------------------------------------------------------------------------*/
  void getDateInRange() {
    DateTime today = DateTime.now();
    toDayDate = formatter.format(today).toString();

    // Get last week range (7 days ago - today)

    DateTime backLastWeek = today.subtract(Duration(days: 7));
    lastWeek = formatter.format(backLastWeek).toString();
    lastWeekDate = "$lastWeek , ${formatter.format(today)}";

    /// Get last month range (30 days ago - today)

    DateTime backLastMonth = DateTime(today.year, today.month - 1, today.day);
    lastMonth = formatter.format(backLastMonth).toString();
    lastMonthDate = "$lastMonth , ${formatter.format(today)}";

    /// Get last 3 months range (3 months ago - today)

    DateTime backLastThreeMonths = DateTime(
      today.year,
      today.month - 3,
      today.day,
    );
    lastThreemonths = formatter.format(backLastThreeMonths).toString();
    lastThreeMonthsDate = "$lastThreemonths , ${formatter.format(today)}";
    update();
  }

  void selectIndex(int index) {
    selectedIndex = index;
    update();
  }

  /*----------------------------------------------------------------------*/
  /*                              get user details                        */
  /*----------------------------------------------------------------------*/
  Future<void> getUserData() async {
    try {
      isGetUserloading = true;
      update();
      var response = await AuthenticationService.getUserDataApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          userData = responseData['data'];
          yourBalance = double.parse(
            (userData?["balance"] == "" ? "0.0" : userData?["balance"] ?? 0.0)
                .toString(),
          );
          partnerBalance = double.parse(
            (userData?["partner"] == "" ? "0.0" : userData?["partner"] ?? 0.0)
                .toString(),
          );
          if (fromDate == null && toDate == null) {
            yourCredit = double.parse(
              (userData?["comission"] == ""
                      ? "0.0"
                      : userData?["comission"] ?? 0.0)
                  .toString(),
            );
          }
          update();
        } else {
          yourCredit = 0.0;
          update();
        }
      } else {
        yourCredit = 0.0;
        update();
      }
    } catch (e) {
      yourCredit = 0.0;
      update();
    } finally {
      isGetUserloading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                            get profit & loss                         */
  /*----------------------------------------------------------------------*/
  Future<void> getProfitLoss() async {
    try {
      update();
      var response = await TradingServices.getProfitLossApi(fromDate, toDate);
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          String profit = (responseData['NetResult'] ?? "0.0").toString();
          totalProfit = double.parse(profit);

          update();
        }
      }
    } catch (e) {}
  }

  /*----------------------------------------------------------------------*/
  /*                            get confirm with draws                   */
  /*----------------------------------------------------------------------*/
  Future<void> getConfirmedWithDraws() async {
    try {
      update();
      var response = await TradingServices.getConfirmedWithdrawApi(
        fromDate,
        toDate,
      );
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
  /*                           get deposits total                         */
  /*----------------------------------------------------------------------*/
  Future<void> getTotalDeposits() async {
    try {
      var response = await TradingServices.getDepositsApi(fromDate, toDate);
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          totalDeposits = double.parse(
            (responseData?['TotalAmount'] ?? 0).toString(),
          );
          update();
        } else {
          totalDeposits = 0.0;
          update();
        }
      } else {
        totalDeposits = 0.0;
        update();
      }
    } catch (e) {
      totalDeposits = 0.0;
      update();
    }
  }
}
