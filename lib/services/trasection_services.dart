import 'package:gfcm_trading/constants/app_url_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrasectionServices {
  /*--------------------------------------------------------------------*/
  /*                     get  wallet trasections history                */
  /*--------------------------------------------------------------------*/

  static Future<http.Response?> getwalletTrasections(
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
          "${AppUrlConstants.walletTrasectionsEndPoint}$userId?limit=$limit&offset=$offset&fromDate=$fromDate&toDate=$toDate",
        );
      } else {
        uri = Uri.parse(
          "${AppUrlConstants.walletTrasectionsEndPoint}$userId?limit=$limit&offset=$offset",
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
  /*                   get account trasections history                  */
  /*--------------------------------------------------------------------*/

  static Future<http.Response?> getAccountTrasections(
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
          "${AppUrlConstants.accountTrasectionendpoint}$userId?offset=$offset&limit=$limit&fromDate=$fromDate&toDate=$toDate",
        );
      } else {
        uri = Uri.parse(
          "${AppUrlConstants.accountTrasectionendpoint}$userId?offset=$offset&limit=$limit",
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
}
