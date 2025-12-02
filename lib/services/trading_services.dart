import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gfcm_trading/constants/app_url_constants.dart';
import 'package:gfcm_trading/global.dart';
import 'package:gfcm_trading/models/close_trades_model.dart';
import 'package:gfcm_trading/models/position_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TradingServices {
  /*--------------------------------------------------------------------*/
  /*                           get user Data                            */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getYourBalanceApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      final uri = Uri.parse(
        "${AppUrlConstants.getBalanceEndPoint}?userid=$userId",
      );

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                     submit commission access request               */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> updateReferralBalanceApi(
    String commissionAmount,
    double partnerBalance,
    int id,
  ) async {
    try {
      final commission = double.parse(commissionAmount);
      final totalAmount = partnerBalance + commission;
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      Uri uri = Uri.parse(AppUrlConstants.updateReferralBalanceEndpoint);

      final response = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userid": userId, "amount": totalAmount, "id": id}),
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                   update your trade positions                      */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> updatePositionsOfTrade(
    List<Position> positions,
    String selectedMode, {
    List<dynamic>? pendingOrders,
  }) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();

      String body;
      final uri = Uri.parse(
        selectedMode == "Real"
            ? AppUrlConstants.updateTradesEndPoint
            : AppUrlConstants.updateDemoTradesEndPoint,
      );

      // Combine positions and pending orders into one list
      List<Map<String, dynamic>> allTrades = [];

      // Add regular positions
      if (positions.isNotEmpty) {
        allTrades.addAll(positions.map((pos) => pos.toJson()).toList());
      }

      // Add pending orders if provided
      if (pendingOrders != null && pendingOrders.isNotEmpty) {
        if (shouldAddPendingOrders) {
          allTrades.addAll(pendingOrders.cast<Map<String, dynamic>>());
          shouldAddPendingOrders = true;
        }
      }

      if (allTrades.isNotEmpty) {
        body = jsonEncode(allTrades);
      } else {
        body = jsonEncode([
          {
            "tradeid": null,
            "userid": userId,
            "side": null,
            "lots": 0,
            "entryPrice": 0,
            "contractSize": 0,
            "marginUsed": 0,
            "openedAt": null,
            "symbol": null,
            "stopLoss": null,
            "takeProfit": null,
          },
        ]);
      }

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                            get your trades                          */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getyourTrades(String selectedmode) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      String userId = sp.getString("userId").toString();
      final uri = Uri.parse(
        selectedmode == "Real"
            ? "${AppUrlConstants.getTradesEndPoint}$userId"
            : "${AppUrlConstants.getDemoTradesEndPoint}$userId",
      );

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                         update your balance                        */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> updateBalance(
    double balance,
    double marginUsed,
    String selectedMode,
    double credit,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      String userId = sp.getString("userId").toString();

      final http.Response response;

      if (selectedMode == "Real") {
        final uri = Uri.parse(AppUrlConstants.updateBalanceEndPoint);
        response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'id': userId,
            'balance': balance,
            'credit': credit,
            'marginused': marginUsed,
          }),
        );
        print(response);
      } else {
        final uri = Uri.parse(AppUrlConstants.updateDemoMarginUsed);

        response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'id': userId, 'demousedmargin': marginUsed}),
        );

        final demoBalanceUri = Uri.parse(
          AppUrlConstants.updateDemoBalanceEndPoint,
        );

        await http.post(
          demoBalanceUri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'id': userId, 'demobalance': balance}),
        );
      }

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                   update your trade positions                      */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> saveCompletedTrades(
    List<CloseTradesModel> closeTradeList,
    String selectedMode,
  ) async {
    try {
      String body;

      final uri = Uri.parse(
        selectedMode == "Real"
            ? AppUrlConstants.saveTradeHistoryEndPoint
            : AppUrlConstants.saveDemoTradeHistoryEndPoint,
      );
      // Convert list of positions to JSON
      body = jsonEncode(closeTradeList.map((pos) => pos.toJson()).toList());
      print(body);
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                          get trade history                         */
  /*--------------------------------------------------------------------*/

  static Future<http.Response?> getTradesHistory(
    int limit,
    int offset,
    String? fromDate,
    String? toDate,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      final String userId = sp.getString("userId") ?? '';

      final selectedMode = sp.getString("selectedMode") ?? "Real";

      Uri uri;
      if (fromDate != null && toDate != null) {
        uri = selectedMode == "Real"
            ? Uri.parse(
                "${AppUrlConstants.getTradehistory}$userId?offset=$offset&limit=$limit&fromdate=$fromDate&todate=$toDate",
              )
            : Uri.parse(
                "${AppUrlConstants.getDemoTradesHistory}$userId?offset=$offset&limit=$limit&fromDate=$fromDate&toDate=$toDate",
              );
      } else {
        uri = Uri.parse(
          "${selectedMode == "Real" ? AppUrlConstants.getTradehistory : AppUrlConstants.getDemoTradesHistory}$userId?offset=$offset&limit=$limit",
        );
      }

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } catch (e) {
      throw "Error fetching trade history: $e";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                          get trade history                         */
  /*--------------------------------------------------------------------*/

  static Future<http.Response?> getLiquitedTradesHistory(
    int limit,
    int offset,
    String? fromDate,
    String? toDate,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      final String userId = sp.getString("userId") ?? '';

      final selectedMode = sp.getString("selectedMode") ?? "Real";

      Uri uri;
      if (fromDate != null && toDate != null) {
        uri = selectedMode == "Real"
            ? Uri.parse(
                "${AppUrlConstants.getLiquitedTradehistory}$userId?offset=$offset&limit=$limit&fromdate=$fromDate&todate=$toDate",
              )
            : Uri.parse(
                "${AppUrlConstants.getDemoLiquitedTradehistory}$userId?offset=$offset&limit=$limit&fromdate=$fromDate&todate=$toDate",
              );
      } else {
        uri = Uri.parse(
          "${selectedMode == "Real" ? AppUrlConstants.getLiquitedTradehistory : AppUrlConstants.getDemoLiquitedTradehistory}$userId?offset=$offset&limit=$limit",
        );
      }

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } catch (e) {
      throw "Error fetching trade history: $e";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                       get Commissions history                      */
  /*--------------------------------------------------------------------*/

  static Future<http.Response?> getCommissionsHistory(
    int limit,
    int offset,
    String? fromDate,
    String? toDate,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      final String userId = sp.getString("userId") ?? '';

      Uri uri;
      if (fromDate != null && toDate != null) {
        uri = Uri.parse(
          "${AppUrlConstants.getCommissionHistoryEndpoint}$userId?fromDate=$fromDate&toDate=$toDate&limit=$limit&offset=$offset",
        );
      } else {
        uri = Uri.parse(
          "${AppUrlConstants.getCommissionHistoryEndpoint}$userId?limit=$limit&offset=$offset",
        );
      }

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );
      return response;
    } catch (e) {
      throw "Error fetching trade history: $e";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                        get profit loss api                         */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getProfitLossApi(
    String? fromDate,
    String? toDate,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      final selectedMode = sp.getString("selectedMode") ?? "Real";

      Uri uri;
      if (fromDate != null && toDate != null) {
        uri = Uri.parse(
          "${selectedMode == "Real" ? AppUrlConstants.getProfitLossApi : AppUrlConstants.getDemoProfitLossApi}$userId?fromdate=$fromDate&todate=$toDate",
        );
      } else {
        uri = Uri.parse(
          "${selectedMode == "Real" ? AppUrlConstants.getProfitLossApi : AppUrlConstants.getDemoProfitLossApi}$userId",
        );
      }

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                      get total deposit api                         */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getDepositsApi(
    String? fromDate,
    String? toDate,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      Uri uri;
      if (fromDate != null && toDate != null) {
        uri = Uri.parse(
          "${AppUrlConstants.getTotalDepositsEndpoint}$userId?fromDate=$fromDate&toDate=$toDate",
        );
      } else {
        uri = Uri.parse("${AppUrlConstants.getTotalDepositsEndpoint}$userId");
      }

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                    get confirmed withDraws api                      */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getConfirmedWithdrawApi(
    String? fromDate,
    String? toDate,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();

      Uri uri;
      if (fromDate != null && toDate != null) {
        uri = Uri.parse(
          "${AppUrlConstants.getConfirmedWitDrawssEndpoint}$userId?fromDate=$fromDate&toDate=$toDate",
        );
      } else {
        uri = Uri.parse(
          "${AppUrlConstants.getConfirmedWitDrawssEndpoint}$userId",
        );
      }

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                     get notification status api                    */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getNotificationStatusApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();

      var uri = Uri.parse(
        "${AppUrlConstants.getNotificationStatusEndPoint}$userId",
      );

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                          get notifications api                     */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getNotificationsApi(
    int notificationCount,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();

      var uri = Uri.parse(
        "${AppUrlConstants.getNotificationsEndPoint}$userId?lastCount=$notificationCount",
      );

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                   update your trade positions                      */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> saveLiquitedTrade(
    String selectedMode,
    String lastPrice,
    String lastBalance,
    String equity,
    String margin,
    String freeMargin,
    String marginLevel,
    String profitLoss,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();

      final uri = Uri.parse(
        selectedMode == "Real"
            ? AppUrlConstants.saveLiquitedTradeEndPoint
            : AppUrlConstants.saveDemoLiquitedTradeEndPoint,
      );

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userId,
          "lastPrice": lastPrice,
          "lastBalance": lastBalance,
          "equity": equity,
          "Margin": margin,
          "FreeMargin": freeMargin,
          "marginLevel": marginLevel,
          "profitLoss": profitLoss,
        }),
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                         get your credit apui                       */
  /*--------------------------------------------------------------------*/

  static Future<http.Response?> getYourCreditApi(
    String fromDate,
    String toDate,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      final String userId = sp.getString("userId") ?? '';

      Uri uri = Uri.parse(
        "${AppUrlConstants.getYourCreditsEndpoint}$userId?startDate=$fromDate&endDate=$toDate",
      );

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } catch (e) {
      throw "Error fetching trade history: $e";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                             get signals api                        */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getSignalsApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();

      var uri = Uri.parse(
        "${AppUrlConstants.getSignalsEndPoint}$userId",
      );

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                              update signal api                     */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> updateSignalsApi({
    required int signalId,
    required String status, // "Accepted" or "Rejected"
  }) async {
    try {
      // Get userId from SharedPreferences
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId")?.toString() ?? "";

      if (userId.isEmpty) {
        throw "User ID not found. Please login again.";
      }

      // Update endpoint to include userId in URL
      var uri = Uri.parse(
        "${AppUrlConstants.updateSignalsEndPoint}",
      );

      // Update body format: { "data": { "userid": userId, "signal_id": signalId, "status": "Accepted" } }
      final response = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": signalId,
          "userid": userId,
          "status": status,
        }),
      );

      return response;
    } on SocketException {
      throw "No Internet connection. Please check your network.";
    } on TimeoutException {
      throw "The connection has timed out. Try again later.";
    } on FormatException {
      throw "Invalid response format. Please contact support.";
    } on HttpException catch (e) {
      throw "Unexpected error occurred: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred: ${e.toString()}";
    }
  }
}
