import 'dart:async';
import 'dart:io';
import 'package:gfcm_trading/constants/app_url_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SocialServices {
  /*--------------------------------------------------------------------*/
  /*                       get give away api call                       */
  /*--------------------------------------------------------------------*/

  static Future<http.Response?> getGiveAwayApi() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId").toString();
      final uri = Uri.parse(
        "${AppUrlConstants.giveAwayApiEndPoint}?userId=$userId",
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

  /*------------------------------------------------------------------*/
  /*                       add proof for reward api                   */
  /*------------------------------------------------------------------*/
  static Future<http.StreamedResponse?> addRewardProofApi(
    String rewardId,
    String rewardUrl,
    File? image,
    File? video,
  ) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("userId").toString();

    try {
      final uri = Uri.parse(AppUrlConstants.addRewardProofEndPoint);

      var request =
          http.MultipartRequest('POST', uri)
            ..fields['userId'] = userId
            ..fields['rewardId'] = rewardId
            ..fields['url'] = rewardUrl
            ..files.add(
              await http.MultipartFile.fromPath(
                'video',
                image == null ? video!.path : image.path,
              ),
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
