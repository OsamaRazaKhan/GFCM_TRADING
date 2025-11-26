import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/constants/data_constants.dart';
import 'package:gfcm_trading/controllers/trade_chart_controller.dart';
import 'package:gfcm_trading/models/gfcm_payment_model.dart';
import 'package:gfcm_trading/models/payment_methods_model.dart';
import 'package:gfcm_trading/services/fund_services.dart';
import 'package:gfcm_trading/services/authentication_service.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_text_form_field.dart';

class TransferController extends GetxController {
  TextEditingController amountController = TextEditingController();
  String? transferFrom;
  String? transferTo;
  bool isTransfer = false;
  Map<String, dynamic>? userData;
  bool isGetData = false;
  String? selectedTabValue;
  List<String> fromList = ['trade', 'partner', 'social', 'wallet'];
  List<String> toList = ['trade', 'partner', 'social', 'wallet'];
  bool isDeleteLoading = false;
  List<PaymentsMethodsModel> activePaymentMethodsList = [];
  List<GfcmPaymentModel> gfcmPaymentMethod = [];
  bool isGetPaymentMethods = false;
  bool isGetPaymentSuccess = false;
  String amountFee = "0.0";
  bool isGetGfcmMethod = false;
  String? selectedDepositMethod; // 'Bank' or 'Crypto'
  GfcmPaymentModel? selectedGfcmPaymentMethod; // Store the specific selected payment method

  void updateFunction() {
    update();
  }

  void updateSelectedTabValue(String value) {
    selectedTabValue = value;
    update();
  }

  /*----------------------------------------------------------------------*/
  /*                        transfer amount fee check                     */
  /*----------------------------------------------------------------------*/
  void setFeeForTransfer() {
    if (transferFrom == 'wallet') {
      amountFee = "0.0";
      update();
    } else if (transferFrom == 'trade' && transferTo == "social" ||
        transferTo == "partner") {
      amountFee = "0.0";
      update();
    } else if (transferFrom == 'social' && transferTo == "partner") {
      amountFee = "0.0";
      update();
    } else if (transferFrom == 'partner' && transferTo == "social") {
      amountFee = "0.0";
      update();
    } else {
      amountFee = "1.2";
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                 select value from search able dropdown               */
  /*----------------------------------------------------------------------*/

  void selectValueFromSearchAbleDropDown(String valueType, String value) {
    if (valueType == 'From') {
      transferFrom = value;
      toList = List.from(DataConstants.transferAccountsList)..remove(value);
      setFeeForTransfer();
      update();
    } else if (valueType == 'To') {
      transferTo = value;
      fromList = List.from(DataConstants.transferAccountsList)..remove(value);
      setFeeForTransfer();
      update();
    } else if (valueType == 'DepositMethod') {
      selectedDepositMethod = value;
      // Clear the stored specific method when dropdown changes
      // User will need to click a specific bank/crypto card to set it again
      selectedGfcmPaymentMethod = null;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/

  String? amountValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter amount";
    }
    return null;
  }

  /*----------------------------------------------------------------------*/
  /*                              transfer amount                         */
  /*----------------------------------------------------------------------*/

  Future<void> transferAmount() async {
    try {
      if (transferFrom == null) {
        FlushMessages.commonToast(
          "Please select 'Transfer From'",
          backGroundColor: colorConstants.dimGrayColor,
        );
        return;
      }
      if (transferTo == null) {
        FlushMessages.commonToast(
          "Please select 'Transfer To'",
          backGroundColor: colorConstants.dimGrayColor,
        );
        return;
      }
      if (transferFrom == transferTo) {
        FlushMessages.commonToast(
          "‘Transfer From’ and ‘Transfer To’ cannot be the same",
          backGroundColor: colorConstants.dimGrayColor,
        );
        return;
      }

      final tradeController = Get.find<TradeChartController>();

      int positionsLength = tradeController.positions.length;
      double marginUsed = tradeController.marginUsed.value;
      double balance = tradeController.balance.value;
      double profitLoss = tradeController.totalUnrealizedPL;

      double transferableAmount;

      if (positionsLength > 0 && transferFrom == "trade") {
        // --- Standard formula ---
        double unrealizedLosses = profitLoss < 0 ? profitLoss.abs() : 0.0;
        transferableAmount = balance - (marginUsed + unrealizedLosses);

        // --- Broker 10% buffer rule ---
        transferableAmount = transferableAmount * 0.9;

        if (transferableAmount < 0) transferableAmount = 0;

        double requestAmount = double.tryParse(amountController.text) ?? 0.0;

        if (requestAmount <= transferableAmount) {
          isTransfer = true;
          update();

          var response = await fundServices.transferAmount(
            transferFrom!,
            amountController.text,
            transferTo!,
          );

          if (response != null) {
            if (response.statusCode == 200) {
              FlushMessages.commonToast(
                "Amount transfer successfully",
                backGroundColor: colorConstants.secondaryColor,
              );
              getUserData(isFirstOpen: false);
              tradeController.getYourBalance();
              update();
            } else {
              var data = jsonDecode(response.body);
              FlushMessages.commonToast(
                data['message'],
                backGroundColor: colorConstants.dimGrayColor,
              );
            }
          } else {
            FlushMessages.commonToast(
              "Something went wrong please try again",
              backGroundColor: colorConstants.dimGrayColor,
            );
          }
        } else {
          FlushMessages.commonToast(
            "You can only transfer $transferableAmount. The amount you entered exceeds your transferable balance",
            backGroundColor: colorConstants.dimGrayColor,
          );
        }
      } else {
        isTransfer = true;
        update();

        var response = await fundServices.transferAmount(
          transferFrom!,
          amountController.text,
          transferTo!,
        );

        if (response != null) {
          if (response.statusCode == 200) {
            FlushMessages.commonToast(
              "Amount transfer successfully",
              backGroundColor: colorConstants.secondaryColor,
            );
            getUserData(isFirstOpen: false);
            tradeController.getYourBalance();
            update();
          } else {
            var data = jsonDecode(response.body);
            FlushMessages.commonToast(
              data['message'],
              backGroundColor: colorConstants.dimGrayColor,
            );
          }
        } else {
          FlushMessages.commonToast(
            "Something went wrong please try again",
            backGroundColor: colorConstants.dimGrayColor,
          );
        }
      }
    } catch (e) {
      FlushMessages.commonToast(
        "$e",
        backGroundColor: colorConstants.dimGrayColor,
      );
    } finally {
      isTransfer = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                              get use data                            */
  /*----------------------------------------------------------------------*/
  Future<void> getUserData({isFirstOpen = true}) async {
    try {
      if (isFirstOpen) {
        isGetData = true;
        update();
      }
      var response = await AuthenticationService.getUserDataApi();
      if (response != null) {
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          userData = responseData['data'];

          update();
        } else {
          userData = null;
          update();
        }
      } else {
        userData = null;
        update();
      }
    } catch (e) {
      userData = null;
      update();
    } finally {
      isGetData = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                      get active payments method                      */
  /*----------------------------------------------------------------------*/
  Future<void> getYourPaymentMethods() async {
    try {
      isGetPaymentMethods = true;
      var response = await fundServices.getYourPaymentMethodsApi();
      if (response != null) {
        if (response.statusCode == 200) {
          isGetPaymentSuccess = true;
          isGetPaymentMethods = false;
          var responseData = jsonDecode(response.body);
          var dataList = responseData['data'];
          activePaymentMethodsList = (dataList as List)
              .map((e) => PaymentsMethodsModel.fromJson(e))
              .toList();

          update();
        } else {
          activePaymentMethodsList = [];
          isGetPaymentSuccess = false;
          update();
        }
      } else {
        activePaymentMethodsList = [];
        isGetPaymentSuccess = false;
        update();
      }
    } catch (e) {
      activePaymentMethodsList = [];
      isGetPaymentSuccess = false;
      update();
    } finally {
      isGetPaymentMethods = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                        deletepayment method                          */
  /*----------------------------------------------------------------------*/
  Future<void> deletePaymentMethod(String id, String userId) async {
    try {
      isDeleteLoading = true;
      update();
      Get.back();
      var response = await fundServices.deleteYourPaymentMethodsApi(id, userId);
      if (response != null) {
        if (response.statusCode == 200) {
          FlushMessages.commonToast(
            "Payment method removed successfully.",
            backGroundColor: colorConstants.secondaryColor,
          );
          isDeleteLoading = false;
          update();
          getYourPaymentMethods();

          update();
        } else {
          FlushMessages.commonToast(
            "Something went wrong please try again",
            backGroundColor: colorConstants.dimGrayColor,
          );
        }
      } else {
        FlushMessages.commonToast(
          "Something went wrong please try again",
          backGroundColor: colorConstants.dimGrayColor,
        );
      }
    } catch (e) {
    } finally {
      isDeleteLoading = false;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                          getGfcm Paayment method                     */
  /*----------------------------------------------------------------------*/
  Future<void> getGfcmPayment() async {
    try {
      isGetGfcmMethod = true;
      var response = await fundServices.getGfcmPaymentMethodsApi();
      if (response != null) {
        if (response.statusCode == 200) {
          isGetPaymentSuccess = true;
          isGetPaymentMethods = false;
          var responseData = jsonDecode(response.body);
          var dataList = responseData['data'];
          gfcmPaymentMethod = (dataList as List)
              .map((e) => GfcmPaymentModel.fromJson(e))
              .toList();
          update();
        } else {
          gfcmPaymentMethod = [];

          update();
        }
      } else {
        gfcmPaymentMethod = [];

        update();
      }
    } catch (e) {
      gfcmPaymentMethod = [];

      update();
    } finally {
      isGetGfcmMethod = false;
      update();
    }
  }
}
