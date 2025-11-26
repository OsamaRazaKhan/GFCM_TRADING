// To parse this JSON data, do
//
//     final liquitedTradesModel = liquitedTradesModelFromJson(jsonString);

import 'dart:convert';

LiquitedTradesModel liquitedTradesModelFromJson(String str) =>
    LiquitedTradesModel.fromJson(json.decode(str));

String liquitedTradesModelToJson(LiquitedTradesModel data) =>
    json.encode(data.toJson());

class LiquitedTradesModel {
  int? userid;
  String? lastPrice;
  String? lastBalance;
  String? equity;
  String? margin;
  String? freeMargin;
  String? marginLevel;
  String? profitLoss;
  String? createdAt;

  LiquitedTradesModel({
    this.userid,
    this.lastPrice,
    this.lastBalance,
    this.equity,
    this.margin,
    this.freeMargin,
    this.marginLevel,
    this.profitLoss,
    this.createdAt,
  });

  factory LiquitedTradesModel.fromJson(Map<String, dynamic> json) =>
      LiquitedTradesModel(
        userid: json["userid"],
        lastPrice: json["lastPrice"],
        lastBalance: json["lastBalance"],
        equity: json["equity"],
        margin: json["Margin"],
        freeMargin: json["FreeMargin"],
        marginLevel: json["marginLevel"],
        profitLoss: json["profitLoss"],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
    "userid": userid,
    "lastPrice": lastPrice,
    "lastBalance": lastBalance,
    "equity": equity,
    "Margin": margin,
    "FreeMargin": freeMargin,
    "marginLevel": marginLevel,
    "profitLoss": profitLoss,
    "created_at": createdAt,
  };
}
