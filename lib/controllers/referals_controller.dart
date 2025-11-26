import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/models/referral_model.dart';
import 'package:gfcm_trading/services/authentication_service.dart';
import 'package:gfcm_trading/services/referal_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_dropdown_widget.dart';
import 'package:intl/intl.dart';

class ReferalsController extends GetxController {
  TextEditingController userIdController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String? selectedCountry;
  String? selectedRefName;
  String referalCode = '';
  List<ReferralModel> yourReferralsList = <ReferralModel>[];
  String totalLots = "0";
  String referralsLength = "0";
  String activeCounts = "0";
  String totalDeposit = "0";
  List<String> countriesNameList = [];
  Set<String> uniqueCountries = {};
  List<String> referralsNameList = [];
  Set<String> uniqueNames = {};
  bool isFilterLoader = false;
  bool isFilterHide = false;

  void getReferralsDetail() {
    startDateController.clear();
    endDateController.clear();
    selectedCountry = null;
    selectedRefName = null;
    getReferralseName();
    getCountries();
    getYourReferalCode();
    getYourReferrals();
    getCountReferalDetail();
    getActiveAccounts();
  }

  void clearFilter() {
    if (startDateController.text.isNotEmpty &&
        endDateController.text.isNotEmpty) {
      startDateController.clear();
      endDateController.clear();
      selectedCountry = null;
      selectedRefName = null;
      getYourReferrals();
    }
  }

  void hideFilter() {
    isFilterHide = !isFilterHide;
    update();
  }

  /*--------------------------------------------------------------------------*/
  /*                                 date selector                            */
  /*--------------------------------------------------------------------------*/
  DateTime selectedDate = DateTime.now();
  Future<void> selectDate(
    BuildContext context,
    TextEditingController dateController,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1910),
      lastDate: DateTime(2201),
    );
    if (picked != null) {
      // Use the date property to keep only the date part without the time component
      selectedDate = DateTime(picked.year, picked.month, picked.day);
      // Format the date using DateFormat
      dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                 select value from search able dropdown               */
  /*----------------------------------------------------------------------*/
  void selectValueFromSearchAbleDropDown(String valueType, String value) {
    if (valueType == 'Country') {
      selectedCountry = value;
      update();
    }
    if (valueType == 'Name') {
      selectedRefName = value;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/

  String? userIdValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter user Id";
    }
    return null;
  }

  String? startDateValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter start date";
    }
    return null;
  }

  String? endDateValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter end date";
    }
    return null;
  }
  /*----------------------------------------------------------------------*/
  /*                             get referalcode                         */
  /*----------------------------------------------------------------------*/

  Future<void> getYourReferalCode() async {
    try {
      var response = await ReferalServices.getReferalCodeApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          referalCode = (responseData?['referralCode'] ?? "");

          update();
        }
      }
    } catch (e) {}
  }

  /*----------------------------------------------------------------------*/
  /*                          get your referals detail                  */
  /*----------------------------------------------------------------------*/

  Future<void> getCountReferalDetail() async {
    try {
      var response = await ReferalServices.getCountReferalDetailApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          totalLots = (responseData?['TotalLots'] ?? 0).toString();

          update();
        }
      }
    } catch (e) {}
  }

  /*----------------------------------------------------------------------*/
  /*                            get active accounts                       */
  /*----------------------------------------------------------------------*/

  Future<void> getActiveAccounts() async {
    try {
      var response = await ReferalServices.getActiveCountsApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          totalDeposit =
              (responseData?['depositorTotalAmount'] ?? 0).toString();
          update();
        }
      }
    } catch (e) {}
  }

  /*----------------------------------------------------------------------*/
  /*                            get countries logic                       */
  /*----------------------------------------------------------------------*/
  Future<void> getCountries() async {
    try {
      countriesNameList.clear();
      uniqueCountries.clear();
      update();
      var response = await AuthenticationService.getCountriesApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          if (responseData['Result'] == "true") {
            for (int i = 0; i < responseData['Data'].length; i++) {
              final country = responseData['Data'][i]['country'];
              if (country != null && uniqueCountries.add(country)) {
                countriesNameList.add(country);
              }
            }
            update();
          } else {
            countriesNameList.clear();
            uniqueCountries.clear();
            update();
          }
        } else {
          countriesNameList.clear();
          uniqueCountries.clear();
          update();
        }
      } else {
        countriesNameList.clear();
        uniqueCountries.clear();
        update();
      }
    } catch (e) {
      countriesNameList.clear();
      uniqueCountries.clear();
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                            get referrals name                        */
  /*----------------------------------------------------------------------*/
  Future<void> getReferralseName() async {
    try {
      referralsNameList.clear();
      uniqueNames.clear();
      update();
      var response = await ReferalServices.getReferralsNameApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          for (int i = 0; i < responseData['data'].length; i++) {
            final name = responseData['data'][i]['firstname'];
            if (name != null && uniqueNames.add(name)) {
              referralsNameList.add(name);
            }
          }
          update();
        } else {
          referralsNameList.clear();
          uniqueNames.clear();
          update();
        }
      } else {
        referralsNameList.clear();
        uniqueNames.clear();
        update();
      }
    } catch (e) {
      referralsNameList.clear();
      uniqueNames.clear();
      update();
    }
  }
  /*-------------------------------------------------------*/
  /*                    get your referrals                 */
  /*-------------------------------------------------------*/

  int referralsLimit = 10; // fixed chunk size
  int referralsOffset = 0; // start at 0
  bool isReferalLoadingMore = false;
  bool hasReferralMoreData = true;

  Future<void> getYourReferrals({
    bool loadMore = false,
    bool isFilter = false,
  }) async {
    if (isFilter) {
      update();
      if (selectedCountry == null) {
        FlushMessages.commonToast(
          "Please select a countary",
          backGroundColor: colorConstants.dimGrayColor,
        );
        return;
      } else if (selectedRefName == null) {
        FlushMessages.commonToast(
          "Please select a name",
          backGroundColor: colorConstants.dimGrayColor,
        );
        return;
      }
      isFilterLoader = true;
    }

    if (loadMore) {
      if (isReferalLoadingMore || !hasReferralMoreData) return;
      isReferalLoadingMore = true;
      referralsOffset += referralsLimit; // move offset forward
    } else {
      referralsOffset = 0; // reset
      yourReferralsList.clear();
      hasReferralMoreData = true;
    }

    try {
      update();
      var response = await ReferalServices.getYourReferralsApi(
        referralsLimit,
        referralsOffset,
        startDateController.text,
        endDateController.text,
        selectedCountry,
        selectedRefName,
      );

      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        activeCounts = (data['totalActiveAccounts'] ?? 0).toString();
        referralsLength = (data['totalRecords'] ?? "0").toString();
        update();

        // handle response being list OR wrapped object with Data / data
        final List<dynamic> referralsJson;
        if (data is List) {
          referralsJson = data;
        } else {
          referralsJson = (data['data'] ?? data['data'] ?? []) as List<dynamic>;
        }

        final List<ReferralModel> yourReferrals =
            referralsJson
                .map((x) => ReferralModel.fromJson(x as Map<String, dynamic>))
                .toList();

        //  Instead of deduplication by key, just append
        if (loadMore) {
          yourReferralsList.addAll(yourReferrals);
        } else {
          yourReferralsList = yourReferrals;
        }

        // check if more data exists
        hasReferralMoreData = yourReferrals.length == referralsLimit;
        isReferalLoadingMore = false;
        update();
      } else {
        hasReferralMoreData = false;
      }
    } catch (e) {
      hasReferralMoreData = false;
    } finally {
      isFilterLoader = false;
      isReferalLoadingMore = false;
      update();
    }
  }
}
