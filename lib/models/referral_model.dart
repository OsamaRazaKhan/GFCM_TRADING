// To parse this JSON data, do
//
//     final referralModel = referralModelFromJson(jsonString);

import 'dart:convert';

ReferralModel referralModelFromJson(String str) =>
    ReferralModel.fromJson(json.decode(str));

String referralModelToJson(ReferralModel data) => json.encode(data.toJson());

class ReferralModel {
  int? id;
  String? role;
  String? firstname;
  String? lastname;
  String? username;
  String? email;
  String? password;
  String? country;
  String? city;
  String? countrycode;
  String? phone;
  String? type;
  String? profile;
  String? verificationno;
  String? doctype;
  String? cnicfront;
  String? cnicback;
  String? selfie;
  String? bill;
  String? passporttype;
  String? passport;
  String? licencetype;
  String? licence;
  String? comission;
  String? balance;
  String? demobalance;
  String? wallet;
  String? partner;
  String? social;
  String? netdeposit;
  String? withdraw;
  int? profit;
  int? loss;
  String? usedmargin;
  int? demousedmargin;
  String? points;
  String? profileverification;
  String? referral;
  String? createdat;

  ReferralModel({
    this.id,
    this.role,
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.password,
    this.country,
    this.city,
    this.countrycode,
    this.phone,
    this.type,
    this.profile,
    this.verificationno,
    this.doctype,
    this.cnicfront,
    this.cnicback,
    this.selfie,
    this.bill,
    this.passporttype,
    this.passport,
    this.licencetype,
    this.licence,
    this.comission,
    this.balance,
    this.demobalance,
    this.wallet,
    this.partner,
    this.social,
    this.netdeposit,
    this.withdraw,
    this.profit,
    this.loss,
    this.usedmargin,
    this.demousedmargin,
    this.points,
    this.profileverification,
    this.referral,
    this.createdat,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) => ReferralModel(
    id: json["id"],
    role: json["role"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    username: json["username"],
    email: json["email"],
    password: json["password"],
    country: json["country"],
    city: json["city"],
    countrycode: json["countrycode"],
    phone: json["phone"],
    type: json["type"],
    profile: json["profile"],
    verificationno: json["verificationno"],
    doctype: json["doctype"],
    cnicfront: json["cnicfront"],
    cnicback: json["cnicback"],
    selfie: json["selfie"],
    bill: json["bill"],
    passporttype: json["passporttype"],
    passport: json["passport"],
    licencetype: json["licencetype"],
    licence: json["licence"],
    comission: json["comission"],
    balance: json["balance"],
    demobalance: json["demobalance"],
    wallet: json["wallet"],
    partner: json["partner"],
    social: json["social"],
    netdeposit: json["netdeposit"],
    withdraw: json["withdraw"],
    profit: json["profit"],
    loss: json["loss"],
    usedmargin: json["usedmargin"],
    demousedmargin: json["demousedmargin"],
    points: json["points"],
    profileverification: json["profileverification"],
    referral: json["referral"],
    createdat: json["createdat"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": role,
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "email": email,
    "password": password,
    "country": country,
    "city": city,
    "countrycode": countrycode,
    "phone": phone,
    "type": type,
    "profile": profile,
    "verificationno": verificationno,
    "doctype": doctype,
    "cnicfront": cnicfront,
    "cnicback": cnicback,
    "selfie": selfie,
    "bill": bill,
    "passporttype": passporttype,
    "passport": passport,
    "licencetype": licencetype,
    "licence": licence,
    "comission": comission,
    "balance": balance,
    "demobalance": demobalance,
    "wallet": wallet,
    "partner": partner,
    "social": social,
    "netdeposit": netdeposit,
    "withdraw": withdraw,
    "profit": profit,
    "loss": loss,
    "usedmargin": usedmargin,
    "demousedmargin": demousedmargin,
    "points": points,
    "profileverification": profileverification,
    "referral": referral,
    "createdat": createdat,
  };
}
