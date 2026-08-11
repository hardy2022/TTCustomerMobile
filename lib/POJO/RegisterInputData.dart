
class RegisterInputData {
  RegisterInputData({

    this.entity_id,
    this.first_name,
    this.last_name,
    this.username,
    this.password,

  });

  String? entity_id;
  String? first_name;
  String? last_name;
  String? username;
  String? password;


  factory RegisterInputData.fromJson(Map<String, dynamic> json) => RegisterInputData(

    entity_id: json["entity_id"],
    first_name: json["first_name"],
    last_name: json["last_name"],
    username: json["username"],
    password: json["password"],

  );

  Map<String, dynamic> toJson() => {

    "entity_id": entity_id,
    "first_name": first_name,
    "last_name": last_name,
    "username": username,
    "password": password,
  };
}