// To parse this JSON data, do
//
//     final paymentsMethodsModel = paymentsMethodsModelFromJson(jsonString);

import 'dart:convert';

PaymentsMethodsModel paymentsMethodsModelFromJson(String str) =>
    PaymentsMethodsModel.fromJson(json.decode(str));

String paymentsMethodsModelToJson(PaymentsMethodsModel data) =>
    json.encode(data.toJson());

class PaymentsMethodsModel {
  int? id;
  int? userid;
  String? paymenttype;
  String? bankname;
  String? accountname;
  String? accountno;
  String? swiftno;
  String? banklogo;
  String? setType;
  String? setAddress;
  String? beneaddress;
  String? setVerification;
  String? status;
  String? createdat;

  PaymentsMethodsModel({
    this.id,
    this.userid,
    this.paymenttype,
    this.bankname,
    this.accountname,
    this.accountno,
    this.swiftno,
    this.banklogo,
    this.setType,
    this.setAddress,
    this.beneaddress,
    this.setVerification,
    this.status,
    this.createdat,
  });

  factory PaymentsMethodsModel.fromJson(Map<String, dynamic> json) =>
      PaymentsMethodsModel(
        id: json["id"],
        userid: json["userid"],
        paymenttype: json["paymenttype"],
        bankname: json["bankname"],
        accountname: json["accountname"],
        accountno: json["accountno"],
        swiftno: json["swiftno"],
        banklogo: json["banklogo"],
        setType: json["setType"],
        setAddress: json["setAddress"],
        beneaddress: json["beneaddress"],
        setVerification: json["setVerification"],
        status: json["status"],
        createdat: json["createdat"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userid": userid,
    "paymenttype": paymenttype,
    "bankname": bankname,
    "accountname": accountname,
    "accountno": accountno,
    "swiftno": swiftno,
    "banklogo": banklogo,
    "setType": setType,
    "setAddress": setAddress,
    "beneaddress": beneaddress,
    "setVerification": setVerification,
    "status": status,
    "createdat": createdat,
  };
}
