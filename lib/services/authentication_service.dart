import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gfcm_trading/constants/app_url_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  /*-------------------------------------------------------*/
  /*                     get countries api                 */
  /*-------------------------------------------------------*/
  static Future<http.Response?> getCountriesApi() async {
    try {
      final uri = Uri.parse(AppUrlConstants.countriesApiEndPoint);

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
  /*                      get cities api                   */
  /*-------------------------------------------------------*/
  static Future<http.Response?> getCitiesApi(String country) async {
    try {
      final uri = Uri.parse(AppUrlConstants.citiesApiEndPoint);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"countryname": country}),
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
  /*                     register user api                 */
  /*-------------------------------------------------------*/
  static Future<http.Response?> registerUserApi(
    String firstName,
    String lastName,
    String email,
    String password,
    String country,
    String city,
    String countryCode,
    String phone,
    String tradingType,
    String refCode,
  ) async {
    try {
      final uri = Uri.parse(AppUrlConstants.registerApiEndPoint);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstname": firstName,
          "lastname": lastName,
          "email": email,
          "password": password,
          "country": country,
          "city": city,
          "countrycode": countryCode,
          "phone": phone,
          "type": tradingType,
          "referral": refCode,
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
  /*                      login user api                   */
  /*-------------------------------------------------------*/
  static Future<http.Response?> loginApi(
    String? emailId,
    String? password,
  ) async {
    try {
      final uri = Uri.parse(AppUrlConstants.loginApiEndPoint);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailId, "password": password}),
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

  /*---------------------------------------------------------------------*/
  /*               get verification code based on email                  */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getCodeApi(String? emailId) async {
    try {
      final uri = Uri.parse(AppUrlConstants.sendVerificationCodeEndPoint);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailId}),
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
  /*                        verify your code api                        */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> verifyYourCodeApi(
    String? code,
    String? email,
  ) async {
    try {
      final uri = Uri.parse(AppUrlConstants.verificationCodeEndPoint);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"verificationcode": code, "email": email}),
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
  /*                        verify your code api                        */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> resetPasswordApi(
    String? userId,
    String? password,
  ) async {
    try {
      final uri = Uri.parse(AppUrlConstants.resetPasswordEndPoint);

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userid": userId, "password": password}),
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
  /*                           get user Data                            */
  /*--------------------------------------------------------------------*/
  static Future<http.Response?> getUserDataApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      final uri = Uri.parse(
        "${AppUrlConstants.getUserDetailApiEndPoint}$userId",
      );

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      print("body data of user=================--_-----__----${response.body}");

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

  /*----------------------------------------------------------*/
  /*                  update user profile api                 */
  /*----------------------------------------------------------*/
  static Future<http.Response?> updateUserProfileApi(
    String firstName,
    String lastName,
    String email,
    String password,
    String country,
    String city,
    String countryCode,
    String phone,
    String tradingType,
    String existingProfileImage,
    File? newProfileImage,
  ) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId") ?? "";

      final String url = "${AppUrlConstants.updeteUserApiEndPoint}$userId";
      final uri = Uri.parse(url);

      var request = http.MultipartRequest('PUT', uri);

      // Form fields
      Map<String, String> data = {
        'firstname': firstName,
        'lastname': lastName,
        'email': email,
        'password': password,
        'country': country,
        'city': city,
        'countrycode': countryCode,
        'phone': phone,
        'type': tradingType,
      };

      // Add text fields
      data.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add image file if new one selected
      if (newProfileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile', newProfileImage.path),
        );
      } else {
        request.fields['profile'] = existingProfileImage;
      }

      request.headers.addAll({'Accept': 'application/json'});
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

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
