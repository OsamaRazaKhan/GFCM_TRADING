import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gfcm_trading/constants/app_url_constants.dart';
import 'package:gfcm_trading/global.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class fundServices {
  /*-------------------------------------------------------*/
  /*                      add payment api                  */
  /*-------------------------------------------------------*/
  static Future<http.StreamedResponse?> addPaymentApi(
    String paymentMethod,
    String paymentType,
    String bankName,
    String accountName,
    String accountNumber,
    String swiftnumber,
    String address,
    File walletpicture,
  ) async {
    http.MultipartRequest request;
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("userId").toString();

    try {
      final uri = Uri.parse(AppUrlConstants.paymentMethodApiEndPoint);
      if (paymentMethod == "Flat") {
        request = http.MultipartRequest('POST', uri)
          ..fields['userid'] = userId
          ..fields['bankname'] = bankName
          ..fields['accountname'] = accountName
          ..fields['accountno'] = accountNumber
          ..fields['swiftno'] = swiftnumber
          ..fields['paymenttype'] = paymentMethod
          ..fields['type'] = paymentType
          ..fields['address'] = address
          ..files.add(
            await http.MultipartFile.fromPath(
              'verification',
              walletpicture.path,
            ),
          );
      } else {
        request = http.MultipartRequest('POST', uri)
          ..fields['userid'] = userId
          ..fields['paymenttype'] = paymentMethod
          ..fields['type'] = paymentType
          ..fields['address'] = address
          ..files.add(
            await http.MultipartFile.fromPath(
              'verification',
              walletpicture.path,
            ),
          );
      }
      final response = await request.send(); // returns StreamedResponse
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

  /*-------------------------------------------------------*/
  /*                     deposit payment                   */
  /*-------------------------------------------------------*/
  static Future<http.StreamedResponse?> depositAmount(
    String currencyType,
    File depositScreenShot,
  ) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("userId").toString();

    try {
      final uri = Uri.parse(AppUrlConstants.depositAmount);

      final request = http.MultipartRequest('POST', uri)
        ..fields['userid'] = userId
        ..fields['amount'] = currencyType
        ..fields['toaccountno'] = globalBankNameOrType
        ..files.add(
          await http.MultipartFile.fromPath(
            'screenshot',
            depositScreenShot.path,
          ),
        );

      final response = await request.send(); // returns StreamedResponse
      globalBankNameOrType = null;

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

  /*-------------------------------------------------------*/
  /*                  transfer amount api                  */
  /*-------------------------------------------------------*/
  static Future<http.Response?> transferAmount(
    String from,
    String amount,
    String to,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();

      final uri = Uri.parse(AppUrlConstants.transferAmount);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userId,
          "from": from,
          "to": to,
          "amount": amount,
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

  /*-------------------------------------------------------*/
  /*                  transfer amount api                  */
  /*-------------------------------------------------------*/
  static Future<http.Response?> withDraw(String wallet, String amount) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      final String postedAt =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final uri = Uri.parse(AppUrlConstants.withDrawEndPoint);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userId,
          "wallet": wallet,
          "amount": amount.trim(),
          "posted_at": postedAt,
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

  /*-------------------------------------------------------*/
  /*              get your payment methods api             */
  /*-------------------------------------------------------*/
  static Future<http.Response?> getYourPaymentMethodsApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      final uri = Uri.parse("${AppUrlConstants.getUserPaymentMethods}$userId");

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

  /*-------------------------------------------------------*/
  /*                 update payment method api              */
  /*-------------------------------------------------------*/
  static Future<http.Response?> updatePaymentMethodApi(
    String id,
    String userId,
  ) async {
    try {
      final http.Response response;

      final uri = Uri.parse(AppUrlConstants.updatePaymentMethodEndPoint);

      response = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'id': id, 'userid': userId, 'status': "active"}),
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
  /*                          get payment types api                      */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getPaymentTypes() async {
    try {
      final uri = Uri.parse(AppUrlConstants.getPaymentTypesEndPoint);

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

  /*-------------------------------------------------------*/
  /*              delete your payment methods api          */
  /*-------------------------------------------------------*/
  static Future<http.Response?> deleteYourPaymentMethodsApi(
    String id,
    String userId,
  ) async {
    try {
      final uri = Uri.parse(AppUrlConstants.deleteYourPaymentMethod);

      final response = await http.delete(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id, "userid": userId}),
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

  /*-------------------------------------------------------*/
  /*                  get gfcm payment method               */
  /*-------------------------------------------------------*/
  static Future<http.Response?> getGfcmPaymentMethodsApi() async {
    try {
      final uri = Uri.parse(AppUrlConstants.getGfcmPaymentMethodEndPoint);

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
