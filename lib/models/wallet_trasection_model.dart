// To parse this JSON data, do
//
//     final walletTrasectionsModel = walletTrasectionsModelFromJson(jsonString);

import 'dart:convert';

WalletTrasectionsModel walletTrasectionsModelFromJson(String str) =>
    WalletTrasectionsModel.fromJson(json.decode(str));

String walletTrasectionsModelToJson(WalletTrasectionsModel data) =>
    json.encode(data.toJson());

class WalletTrasectionsModel {
  int? id;
  int? userid;
  String? wallet;
  String? amount;
  String? currency;
  String? status;
  String? datetime;
  String? type;
  String? transactiontype;

  WalletTrasectionsModel({
    this.id,
    this.userid,
    this.wallet,
    this.amount,
    this.currency,
    this.status,
    this.datetime,
    this.type,
    this.transactiontype,
  });

  factory WalletTrasectionsModel.fromJson(Map<String, dynamic> json) =>
      WalletTrasectionsModel(
        id: json["id"],
        userid: json["userid"],
        wallet: json["wallet"],
        amount: json["amount"],
        currency: json["currency"],
        status: json["status"],
        datetime: json["datetime"],
        type: json["type"],
        transactiontype: json["transactiontype"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userid": userid,
    "wallet": wallet,
    "amount": amount,
    "currency": currency,
    "status": status,
    "datetime": datetime,
    "type": type,
    "transactiontype": transactiontype,
  };
}
