
class CustomerProfileResponse {
  CustomerProfileResponse({

    this.id,
    this.customer_id,
    this.address1,
    this.address2,
    this.gender,
    this.email_id,
    this.user,
    this.message,
    this.description,



  });


  String? id;
  int? customer_id;
  String? address1;
  String? address2;
  String? gender;
  String? email_id;
  UserData? user;
  String? message;
  String? description;




  factory CustomerProfileResponse.fromJson(Map<String, dynamic> json) =>
      CustomerProfileResponse(


        id: json["id"],
        customer_id: json["customer_id"],
        address1: json["address1"],
        address2: json["address2"],
        gender: json["gender"],
        email_id: json["email_id"],
        message: json["message"],
        description: json["description"],
        user: json["user"] != null ? UserData.fromJson(json["user"]) : null, // No need to use map

      );

  Map<String, dynamic> toJson() => {


    "user": user,
    "id": id,
    "customer_id": customer_id,
    "address1": address1,
    "address2": address2,
    "gender": gender,
    "email_id": email_id,
    "message": message,
    "description": description,



  };
}


class UserData {

  int? id;
  int? entity_id;
  String? birth_date;
  String? device_token;
  String? location;
  String? username;
  String? email_id;
  bool? is_active;
  String? created;
  String? entity;
  String? first_name;
  String? last_name;
  String? mobile_no;
  String? profile_image;

  UserData({
    this.id,
    this.entity_id,
    this.birth_date,
    this.device_token,
    this.location,
    this.username,
    this.email_id,
    this.is_active,
    this.created,
    this.entity,
    this.first_name,
    this.last_name,
    this.mobile_no,
    this.profile_image,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(

      id: json["id"],
      entity_id: json["entity_id"],
      first_name: json["first_name"],
      last_name: json["last_name"],
      mobile_no: json["mobile_no"],
      birth_date: json["birth_date"],
      device_token: json["device_token"],
      location: json["location"],
      profile_image: json["profile_image"],
      username: json["username"],
      email_id: json["email_id"],
      is_active: json["is_active"],
      created: json["created"],
      entity: json["entity"],

    );
  }

  Map<String, dynamic> toJson() {
    return {

      "id": id,
      "entity_id": entity_id,
      "first_name": first_name,
      "last_name": last_name,
      "mobile_no": mobile_no,
      "birth_date": birth_date,
      "device_token": device_token,
      "location": location,
      "profile_image": profile_image,
      "username": username,
      "email_id": email_id,
      "is_active": is_active,
      "created": created,
      "entity": entity,


    };
  }
}

