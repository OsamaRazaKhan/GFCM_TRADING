import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/models/account_trasection_model.dart';
import 'package:gfcm_trading/models/wallet_trasection_model.dart';
import 'package:gfcm_trading/services/trasection_services.dart';
import 'package:intl/intl.dart';

class TransactionController extends GetxController {
  String? wStartDate;
  String? wEndDate;
  String? aStartDate;
  String? aEndDate;

  List<WalletTrasectionsModel> walletTrasectionsList =
      <WalletTrasectionsModel>[];

  List<AccountTrasectionsModel> accountTrasectionList =
      <AccountTrasectionsModel>[];

  String? fromDate;
  String? toDate;

  void clearDate() {
    fromDate = null;
    toDate = null;
  }

  bool isWalletFilter = false;
  bool isAccountFilter = false;

  void selectFilter(String isWalletOrAccount) {
    if (isWalletOrAccount == "wallet") {
      isWalletFilter = !isWalletFilter;
    } else {
      isAccountFilter = !isAccountFilter;
    }
    update();
  }

  /*--------------------------------------------------------------------------*/
  /*                             select date in range                            */
  /*--------------------------------------------------------------------------*/

  Future<void> selectDate(BuildContext context, String type) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1910),
      lastDate: DateTime(2201),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 7)),
      ),
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

      if (type == "wallet") {
        getWalletTrasection();
      } else {
        getAcountTrasection();
      }

      update();
    }
  }

  String formatWalletDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return dateStr;
      
      // Parse the datetime string
      DateTime date = DateTime.parse(dateStr);
      
      // Check if the string indicates UTC timezone
      final upperDateStr = dateStr.toUpperCase();
      final isUtc = upperDateStr.endsWith('Z') || 
                    dateStr.contains('+00:00') || 
                    dateStr.endsWith('+00:00');
      
      // If the datetime is in UTC, convert to local time
      // DateTime.parse() with 'Z' creates a UTC DateTime, we need to convert to local
      if (isUtc) {
        // Already UTC, convert to local time
        date = date.toLocal();
      } else {
        // Check if there's timezone info in the string
        final hasTimezone = dateStr.contains('+') || 
                           (dateStr.contains('-') && dateStr.contains('T') && 
                            dateStr.split('T').length > 1 && 
                            dateStr.split('T')[1].contains('-'));
        
        // If no timezone info and it's an ISO format, assume UTC
        if (!hasTimezone && dateStr.contains('T')) {
          // Parse as UTC and convert to local
          if (!upperDateStr.endsWith('Z')) {
            date = DateTime.parse(dateStr + 'Z').toLocal();
          } else {
            date = date.toLocal();
          }
        }
        // If it has timezone info, DateTime.parse() handles it correctly
        // and we just need to ensure it's in local time
        else if (date.isUtc) {
          date = date.toLocal();
        }
      }
      
      // Format in local timezone
      return DateFormat("dd MMM,yy h:mm a").format(date);
    } catch (e) {
      // Fallback: try to parse as UTC and convert
      try {
        final cleanDateStr = dateStr.trim();
        final dateStrWithZ = cleanDateStr.toUpperCase().endsWith('Z') 
            ? cleanDateStr 
            : cleanDateStr + 'Z';
        DateTime date = DateTime.parse(dateStrWithZ);
        return DateFormat("dd MMM,yy h:mm a").format(date.toLocal());
      } catch (e2) {
        return dateStr; // final fallback
      }
    }
  }

  String toCamel(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  /*--------------------------------------------------*/
  /*                get wallet trasections            */
  /*--------------------------------------------------*/

  int walletLimit = 20; // fixed chunk size
  int walletOffset = 0; // start at 0
  bool walletIsLoadingMore = false;
  bool walletHasMoreData = true;

  Future<void> getWalletTrasection({bool loadMore = false}) async {
    if (loadMore) {
      if (walletIsLoadingMore || !walletHasMoreData) return;
      walletIsLoadingMore = true;
      walletOffset += walletLimit; // move offset forward
    } else {
      walletOffset = 0; // reset
      walletTrasectionsList.clear();
      walletHasMoreData = true;
    }

    try {
      update();
      var response = await TrasectionServices.getwalletTrasections(
        walletLimit,
        walletOffset,
        fromDate,
        toDate,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // handle response being list OR wrapped object with Data / data
        final List<dynamic> walletJson;
        if (data is List) {
          walletJson = data;
        } else {
          walletJson = (data['Data'] ?? data['data'] ?? []) as List<dynamic>;
        }

        final List<WalletTrasectionsModel> newTrades =
            walletJson
                .map(
                  (x) => WalletTrasectionsModel.fromJson(
                    x as Map<String, dynamic>,
                  ),
                )
                .toList();

        //  Instead of deduplication by key, just append
        if (loadMore) {
          walletTrasectionsList.addAll(newTrades);
        } else {
          walletTrasectionsList = newTrades;
        }

        // check if more data exists
        walletHasMoreData = newTrades.length == walletLimit;
      } else {
        walletHasMoreData = false;
      }
    } catch (e) {
      walletHasMoreData = false;
    } finally {
      walletIsLoadingMore = false;
      update();
    }
  }

  /*--------------------------------------------------*/
  /*                get Account trasections            */
  /*--------------------------------------------------*/

  int accountLimit = 20; // fixed chunk size
  int accountOffset = 0; // start at 0
  bool accountIsLoadingMore = false;
  bool accountHasMoreData = true;

  Future<void> getAcountTrasection({bool loadMore = false}) async {
    if (loadMore) {
      if (accountIsLoadingMore || !accountHasMoreData) return;
      accountIsLoadingMore = true;
      accountOffset += accountLimit; // move offset forward
    } else {
      accountOffset = 0; // reset
      accountTrasectionList.clear();
      accountHasMoreData = true;
    }

    try {
      update();
      var response = await TrasectionServices.getAccountTrasections(
        accountLimit,
        accountOffset,
        fromDate,
        toDate,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // handle response being list OR wrapped object with Data / data
        final List<dynamic> accountJson;
        if (data is List) {
          accountJson = data;
        } else {
          accountJson = (data['data'] ?? data['data'] ?? []) as List<dynamic>;
        }

        final List<AccountTrasectionsModel> accountTrasections =
            accountJson
                .map(
                  (x) => AccountTrasectionsModel.fromJson(
                    x as Map<String, dynamic>,
                  ),
                )
                .toList();

        //  Instead of deduplication by key, just append
        if (loadMore) {
          accountTrasectionList.addAll(accountTrasections);
        } else {
          accountTrasectionList = accountTrasections;
        }

        // check if more data exists
        accountHasMoreData = accountTrasections.length == accountLimit;
      } else {
        accountHasMoreData = false;
      }
    } catch (e) {
      accountHasMoreData = false;
    } finally {
      accountIsLoadingMore = false;
      update();
    }
  }
}
