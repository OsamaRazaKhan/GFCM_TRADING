class GfcmPaymentModel {
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
  String? firstname;
  String? lastname;

  GfcmPaymentModel({
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
    this.firstname,
    this.lastname,
  });

  factory GfcmPaymentModel.fromJson(Map<String, dynamic> json) =>
      GfcmPaymentModel(
        id: json["id"],
        userid: json["userid"],
        paymenttype: json["paymenttype"]?.toString(),
        bankname: json["bankname"]?.toString(),
        accountname: json["accountname"]?.toString(),
        accountno: json["accountno"]?.toString(),
        swiftno: json["swiftno"]?.toString(),
        banklogo: json["banklogo"]?.toString(),
        setType: json["setType"]?.toString(),
        setAddress: json["setAddress"]?.toString(),
        beneaddress: json["beneaddress"]?.toString(),
        setVerification: json["setVerification"]?.toString(),
        status: json["status"]?.toString(),
        createdat: json["createdat"]?.toString(),
        firstname: json["firstname"]?.toString(),
        lastname: json["lastname"]?.toString(),
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
        "firstname": firstname,
        "lastname": lastname,
      };
}
