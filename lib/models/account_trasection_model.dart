// To parse this JSON data, do
//
//     final accountTrasectionsModel = accountTrasectionsModelFromJson(jsonString);

class AccountTrasectionsModel {
  int? id;
  int? userid;
  String? fromaccount;
  String? toaccount;
  String? amount; // <-- changed from int? to String?
  String? transferredAt;
  String? firstname;
  String? lastname;
  String? email;
  String? datetime;
  String? type;
  String? status;

  AccountTrasectionsModel({
    this.id,
    this.userid,
    this.fromaccount,
    this.toaccount,
    this.amount,
    this.transferredAt,
    this.firstname,
    this.lastname,
    this.email,
    this.datetime,
    this.type,
    this.status,
  });

  factory AccountTrasectionsModel.fromJson(Map<String, dynamic> json) =>
      AccountTrasectionsModel(
        id: json["id"],
        userid: json["userid"],
        fromaccount: json["fromaccount"]?.toString(),
        toaccount: json["toaccount"]?.toString(),
        amount: json["amount"]?.toString(), // <-- safe conversion
        transferredAt: json["transferred_at"]?.toString(),
        firstname: json["firstname"]?.toString(),
        lastname: json["lastname"]?.toString(),
        email: json["email"]?.toString(),
        datetime: json["datetime"]?.toString(),
        type: json["type"]?.toString(),
        status: json["status"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userid": userid,
    "fromaccount": fromaccount,
    "toaccount": toaccount,
    "amount": amount, // stays string
    "transferred_at": transferredAt,
    "firstname": firstname,
    "lastname": lastname,
    "email": email,
    "datetime": datetime,
    "type": type,
    "status": status,
  };
}
