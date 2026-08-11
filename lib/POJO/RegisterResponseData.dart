class RegisterResponseData {
  RegisterResponseData({
    this.created,
    this.entity_id,
    this.first_name,
    this.id,
    this.last_name,
    this.otp,
    this.username,
    this.message,
    this.description,
    this.code,


  });

  String? created;
  String? entity_id;
  String? first_name;
  int? id;
  String? last_name;
  int? otp;
  String? username;
  String? message;
  String? description;
  int? code;





  factory RegisterResponseData.fromJson(Map<String, dynamic> json) => RegisterResponseData(
    created: json["created"],
    entity_id: json["entity_id"],
    first_name: json["first_name"],
    id: json["id"],
    last_name: json["last_name"],
    otp: json["otp"],
    username: json["username"],
    message: json["message"],
    description: json["description"],
    code: json["code"],


  );

  Map<String, dynamic> toJson() => {
    "created": created,
    "entity_id": entity_id,
    "first_name": first_name,
    "id": id,
    "last_name": last_name,
    "otp": otp,
    "username": username,
    "message": message,
    "description": description,
    "code": code,
  };
}
