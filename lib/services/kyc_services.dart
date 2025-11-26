import 'dart:async';
import 'dart:io';
import 'package:gfcm_trading/constants/app_url_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KycServices {
  /*-------------------------------------------------------*/
  /*                     register user api                 */
  /*-------------------------------------------------------*/
  static Future<http.StreamedResponse?> verifyYourIdentityApi(
    String doctype,
    File frontIdImage,
    File? backIdImage,
    File selfie,
    File billImage,
  ) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("userId").toString();

    try {
      final uri = Uri.parse(AppUrlConstants.kycVerificationEndPoint);

      var request =
          http.MultipartRequest('PUT', uri)
            ..fields['id'] =
                userId // Add text fields
            ..fields['doctype'] = doctype
            ..files.add(
              await http.MultipartFile.fromPath('passport', frontIdImage.path),
            )
            ..files.add(
              await http.MultipartFile.fromPath('cnicfront', frontIdImage.path),
            )
            ..files.add(
              await http.MultipartFile.fromPath(
                'cnicback',
                backIdImage?.path ?? frontIdImage.path,
              ),
            )
            ..files.add(
              await http.MultipartFile.fromPath('selfie', selfie.path),
            )
            ..files.add(
              await http.MultipartFile.fromPath('bill', billImage.path),
            );

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
}
