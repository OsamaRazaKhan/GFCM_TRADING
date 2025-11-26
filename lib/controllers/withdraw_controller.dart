import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gfcm_trading/controllers/transfer_controller.dart';
import 'package:gfcm_trading/services/fund_services.dart';
import 'package:gfcm_trading/utils/flush_messages.dart';
import 'package:gfcm_trading/views/custom_widgets/custom_dropdown_widget.dart';

class WithdrawController extends GetxController {
  TextEditingController amountController = TextEditingController();
  String? selectedWallet;
  String? selectCurrency;
  bool isWithDraw = false;
  /*----------------------------------------------------------------------*/
  /*                 select value from search able dropdown               */
  /*----------------------------------------------------------------------*/
  void selectValueFromSearchAbleDropDown(String valueType, String value) {
    if (valueType == 'Wallet') {
      selectedWallet = value;
      update();
    }
    if (valueType == 'Currency') {
      selectCurrency = value;
      update();
    }
  }

  /*----------------------------------------------------------------------*/
  /*                         check and validations                        */
  /*----------------------------------------------------------------------*/

  String? feeValidate(value) {
    if (value == null || value.trim().isEmpty) {
      return "Please must enter amount";
    }
    return null;
  }

  /*----------------------------------------------------------------------*/
  /*                             witdraw amount                           */
  /*----------------------------------------------------------------------*/
  Future<void> withDrawAmount() async {
    TransferController transferController;

    if (!Get.isRegistered<TransferController>()) {
      transferController = Get.put(TransferController());
    } else {
      transferController = Get.find<TransferController>();
    }

    double walletAmount = double.parse(
      transferController.userData?['wallet'] == null
          ? "0.0"
          : transferController.userData?['wallet'] == ""
          ? "0.0"
          : transferController.userData!['wallet'].toString(),
    );

    try {
      if (selectedWallet == null) {
        FlushMessages.commonToast(
          "Please select 'wallet'",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else if (walletAmount < 30.0) {
        FlushMessages.commonToast(
          "You can withdraw once your wallet balance is at least \$30",
          backGroundColor: colorConstants.dimGrayColor,
        );
      } else {
        isWithDraw = true;
        update();
        var response = await fundServices.withDraw(
          selectedWallet!,
          amountController.text,
        );
        if (response != null) {
          if (response.statusCode == 201) {
            var data = jsonDecode(response.body);
            FlushMessages.commonToast(
              data['ResponseMsg'],
              backGroundColor: colorConstants.secondaryColor,
            );
            transferController.getUserData(isFirstOpen: false);

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
      isWithDraw = false;
      update();
    }
  }
}
