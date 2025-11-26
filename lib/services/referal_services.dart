import 'dart:async';
import 'dart:io';

import 'package:gfcm_trading/constants/app_url_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReferalServices {
  static Future<http.Response?> getReferalCodeApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      String userId = sp.getString("userId").toString();

      final uri = Uri.parse("${AppUrlConstants.getReferalCodeEndpoint}$userId");

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
  /*                           get your referrals                       */
  /*--------------------------------------------------------------------*/

  static Future<http.Response?> getYourReferralsApi(
    int limit,
    int offset,
    String? fromDate,
    String? toDate,
    String? country,
    String? city,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      final String userId = sp.getString("userId") ?? '';

      Uri uri;
      if (fromDate != null &&
          fromDate.isNotEmpty &&
          toDate != null &&
          toDate.isNotEmpty) {
        uri = Uri.parse(
          "${AppUrlConstants.getYourReferrals}$userId?country=$country&name=$city&startDate=$fromDate&endDate=$toDate&offset=$offset&limit=$limit",
        );
      } else {
        uri = Uri.parse(
          "${AppUrlConstants.getYourReferrals}$userId?$offset=$offset&limit=$limit",
        );
      }

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      return response;
    } catch (e) {
      throw "$e";
    }
  }

  /*--------------------------------------------------------------------*/
  /*                           get referal Name                        */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getReferralsNameApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      String userId = sp.getString("userId").toString();

      final uri = Uri.parse("${AppUrlConstants.getYourReferrals}$userId");

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
  /*                           get Counts referal                       */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getCountReferalDetailApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      String userId = sp.getString("userId").toString();

      final uri = Uri.parse(
        "${AppUrlConstants.getCountReferalsEndpoint}$userId",
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
  /*                           get active counts                         */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getActiveCountsApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();

      String userId = sp.getString("userId").toString();

      final uri = Uri.parse(
        "${AppUrlConstants.getActiveAccountsEndPoint}$userId",
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
}
