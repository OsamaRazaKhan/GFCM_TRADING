import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gfcm_trading/constants/app_url_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeServices {
  static Future<http.Response?> getDemoBalance() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      final uri = Uri.parse(
        "${AppUrlConstants.getDemoBalanceEndPoint}?userid=$userId",
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
  /*                      update your demo balance                      */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> updateDemoBalance(String demoBalance) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      String userId = sp.getString("userId").toString();

      final uri = Uri.parse(AppUrlConstants.updateDemoBalanceEndPoint);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'id': userId, 'demobalance': demoBalance}),
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
