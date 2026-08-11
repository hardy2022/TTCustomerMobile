class ProfileInputData {
  ProfileInputData({
    this.first_name,
    this.last_name,
    this.mobile_no,
    this.location,
    this.profile_image,
    this.email_id,
    this.address1,
    this.address2,

  });

  String? first_name;
  String? last_name;
  String? mobile_no;
  String? location;
  String? profile_image;
  String? email_id;
  String? address1;
  String? address2;



  factory ProfileInputData.fromJson(Map<String, dynamic> json) =>
      ProfileInputData(
        first_name: json["first_name"],
        last_name: json["last_name"],
        mobile_no: json["mobile_no"],
        location: json["location"],
        profile_image: json["profile_image"],
        email_id: json["email_id"],
        address1: json["address1"],
        address2: json["address2"],



      );

  Map<String, dynamic> toJson() => {
    "first_name": first_name,
    "last_name": last_name,
    "mobile_no": mobile_no,
    "location": location,
    "profile_image": profile_image,
    "email_id": email_id,
    "address1": address1,
    "address2": address2,



  };
}
