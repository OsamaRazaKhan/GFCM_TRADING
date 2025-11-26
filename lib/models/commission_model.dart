// To parse this JSON data, do
//
//     final commissionDetailModel = commissionDetailModelFromJson(jsonString);

import 'dart:convert';

CommissionDetailModel commissionDetailModelFromJson(String str) =>
    CommissionDetailModel.fromJson(json.decode(str));

String commissionDetailModelToJson(CommissionDetailModel data) =>
    json.encode(data.toJson());

class CommissionDetailModel {
  int? id;
  int? userid;
  String? fromaccountname;
  String? fromaccountno;
  String? toaccountname;
  String? toaccountno;
  String? amount;
  String? status;
  String? type;
  String? fromid;
  String? credittype;
  String? screenshot;
  String? current;
  String? createdOn;
  String? firstname;
  String? lastname;
  String? email;
  String? fromUserFullname;
  String? fromUserFirstname;
  String? fromUserLastname;
  String? fromUserEmail;

  CommissionDetailModel({
    this.id,
    this.userid,
    this.fromaccountname,
    this.fromaccountno,
    this.toaccountname,
    this.toaccountno,
    this.amount,
    this.status,
    this.type,
    this.fromid,
    this.credittype,
    this.screenshot,
    this.current,
    this.createdOn,
    this.firstname,
    this.lastname,
    this.email,
    this.fromUserFullname,
    this.fromUserFirstname,
    this.fromUserLastname,
    this.fromUserEmail,
  });

  factory CommissionDetailModel.fromJson(Map<String, dynamic> json) =>
      CommissionDetailModel(
        id: json["id"],
        userid: json["userid"],
        fromaccountname: json["fromaccountname"],
        fromaccountno: json["fromaccountno"],
        toaccountname: json["toaccountname"],
        toaccountno: json["toaccountno"],
        amount: json["amount"],
        status: json["status"],
        type: json["type"],
        fromid: json["fromid"],
        credittype: json["credittype"],
        screenshot: json["screenshot"],
        current: json["current"],
        createdOn: json["created_on"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        email: json["email"],
        fromUserFullname: json["fromUserFullname"],
        fromUserFirstname: json["fromUserFirstname"],
        fromUserLastname: json["fromUserLastname"],
        fromUserEmail: json["fromUserEmail"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userid": userid,
    "fromaccountname": fromaccountname,
    "fromaccountno": fromaccountno,
    "toaccountname": toaccountname,
    "toaccountno": toaccountno,
    "amount": amount,
    "status": status,
    "type": type,
    "fromid": fromid,
    "credittype": credittype,
    "screenshot": screenshot,
    "current": current,
    "created_on": createdOn,
    "firstname": firstname,
    "lastname": lastname,
    "email": email,
    "fromUserFullname": fromUserFullname,
    "fromUserFirstname": fromUserFirstname,
    "fromUserLastname": fromUserLastname,
    "fromUserEmail": fromUserEmail,
  };
}
