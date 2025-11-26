class AppUrlConstants {
  static String baseUrl = "https://backend.gfcmgroup.com/api/";
  
  // New alias key requested for admin payment method endpoint
  static String gfcmaacountkey = "${baseUrl}adminpaymentmethod";
  static String registerApiEndPoint = "${baseUrl}register";
  static String countriesApiEndPoint = "${baseUrl}countries";
  static String citiesApiEndPoint = "${baseUrl}cities";
  static String loginApiEndPoint = "${baseUrl}login";
  static String sendVerificationCodeEndPoint =
      "${baseUrl}send-verification-code";
  static String verificationCodeEndPoint = "${baseUrl}verify-code";
  static String resetPasswordEndPoint = "${baseUrl}update-password";
  static String kycVerificationEndPoint = "${baseUrl}profileverification";
  static String paymentMethodApiEndPoint = "${baseUrl}paymentmethod";
  static String updeteUserApiEndPoint = "${baseUrl}users/update/";
  static String getUserDetailApiEndPoint = "${baseUrl}users/";

  static String getBalanceEndPoint = "${baseUrl}get-balance";


  //api for the trade
  static String updateTradesEndPoint = "${baseUrl}trades/save";


// this api is used to get the trade data from the api/ admin pannel 
  static String getTradesEndPoint = "${baseUrl}trades/";

  static String updateBalanceEndPoint = "${baseUrl}update-balance";

  // saving the trade history data to the backend (post)
  static String saveTradeHistoryEndPoint = "${baseUrl}tradehistory/save";



  //geting history data from the backend for the real (get)
  static String getTradehistory = "${baseUrl}tradehistory/summary/confirmed/";




  static String depositAmount = "${baseUrl}deposittobalance";
  static String transferAmount = "${baseUrl}transfer";  
  static String withDrawEndPoint = "${baseUrl}withdraw-request";
  static String walletTrasectionsEndPoint = "${baseUrl}withdrawdata/confirmed/";
  static String accountTrasectionendpoint = "${baseUrl}transactionhistory/";
  static String updateDemoTradesEndPoint = "${baseUrl}demotradeforuser/save";
  static String getDemoTradesEndPoint = "${baseUrl}demotrades/";
  static String updateDemoMarginUsed = "${baseUrl}update-demomarginused";
  static String getDemoBalanceEndPoint = "${baseUrl}getdemobalance";
  static String updateDemoBalanceEndPoint = "${baseUrl}update-demobalance";
  static String getProfitLossApi = "${baseUrl}tradehistory/summary/confirmed/";
  static String getTotalDepositsEndpoint =
      "${baseUrl}depositbalance/confirmed/";
  static String saveDemoTradeHistoryEndPoint =
      "${baseUrl}demotradehistoryforuser/save";
  static String getDemoTradesHistory = "${baseUrl}demodata/tradehistory/";
  static String getConfirmedWitDrawssEndpoint =
      "${baseUrl}withdrawdata/confirmed/";
  static String getDemoProfitLossApi =
      "${baseUrl}demotradehistoryforuser/summary/confirmed/";
  static String giveAwayApiEndPoint = "${baseUrl}usergiveawaysdata";
  static String addRewardProofEndPoint = "${baseUrl}applyforreward";
  static String getNotificationStatusEndPoint =
      "${baseUrl}notifications/count/";
  static String getNotificationsEndPoint = "${baseUrl}notifications/";
  static String getLiquitedTradehistory = "${baseUrl}liquidated/history/";
  static String saveLiquitedTradeEndPoint = "${baseUrl}liquidated";
  static String getDemoLiquitedTradehistory =
      "${baseUrl}demoliquidated/history/";
  static String saveDemoLiquitedTradeEndPoint = "${baseUrl}demoliquidated";
  static String getReferalCodeEndpoint = "${baseUrl}referral/";
  static String getCommissionHistoryEndpoint = "${baseUrl}referraldepositdata/";
  static String getCountReferalsEndpoint =
      "${baseUrl}profitloseforreferaluser/referral/";
  static String getUserPaymentMethods = "${baseUrl}getalluserpaymentmethods/";
  static String getYourReferrals = "${baseUrl}myreferrals/";
  static String getActiveAccountsEndPoint = "${baseUrl}referraldepositdata/";
  static String updatePaymentMethodEndPoint =
      "${baseUrl}update/userpayment/status";
  static String getPaymentTypesEndPoint = "${baseUrl}type";
  static String deleteYourPaymentMethod = "${baseUrl}paymentmethod";
  static String getYourCreditsEndpoint = "${baseUrl}mycredits/";
  static String updateReferralBalanceEndpoint =
      "${baseUrl}update-partner-balance";


  //geting signals data from the backend for the real (get)
  static String getSignalsEndPoint = "${baseUrl}signals/user/";
  //updating the signal status to the backend (post)
  static String updateSignalsEndPoint = "${baseUrl}signals/updatestatus";


  static String getGfcmPaymentMethodEndPoint = "${baseUrl}adminpaymentmethod";
}
