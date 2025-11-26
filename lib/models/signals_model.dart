class SignalsModel {
  int? id;
  String? userid;
  String? firstname;
  String? lastname;
  String? validtill;
  String? message;
  String? status;
  int? timer; // Timer in seconds from API

  SignalsModel({
    this.id,
    this.userid,
    this.firstname,
    this.lastname,
    this.validtill,
    this.message,
    this.status,
    this.timer,
  });

  factory SignalsModel.fromJson(Map<String, dynamic> json) => SignalsModel(
        id: json["id"],
        userid: json["userid"],
        firstname: json["firstname"]?.toString(),
        lastname: json["lastname"]?.toString(),
        validtill: json["validtill"]?.toString(),
        message: json["message"]?.toString(),
        status: json["status"]?.toString(),
        timer: json["timer"] != null ? (json["timer"] is int ? json["timer"] : int.tryParse(json["timer"].toString())) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userid": userid,
        "firstname": firstname,
        "lastname": lastname,
        "validtill": validtill,
        "message": message,
        "status": status,
        "timer": timer,
      };
}
