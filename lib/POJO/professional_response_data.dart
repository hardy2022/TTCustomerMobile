class ProfessionalResponseData {
  ProfessionalResponseData({
    this.vendor_id,
    this.first_name,
    this.last_name,
    this.business_name,
    this.logo,
    this.profile_image,
    this.professional_name,
    this.location,
    this.service_latitude,
    this.service_longitude,
    this.business_description,
    this.cost,


  });

  int? vendor_id;
  String? first_name;
  String? last_name;
  String? business_name;
  String? logo;
  String? profile_image;
  String? professional_name;
  String? location;
  String? service_latitude;
  String? service_longitude;
  String? business_description;
  String? cost;




  factory ProfessionalResponseData.fromJson(Map<String, dynamic> json) => ProfessionalResponseData(
    vendor_id: json["vendor_id"],
    first_name: json["first_name"],
    last_name: json["last_name"],
    business_name: json["business_name"],
    logo: json["logo"],
    profile_image: json["profile_image"],
    professional_name: json["professional_name"],
    location: json["location"],
    service_latitude: json["service_latitude"],
    service_longitude: json["service_longitude"],
    business_description: json["business_description"],
    cost: json["cost"],


  );

  Map<String, dynamic> toJson() => {
    "vendor_id": vendor_id,
    "first_name": first_name,
    "last_name": last_name,
    "business_name": business_name,
    "logo": logo,
    "profile_image": profile_image,
    "professional_name": professional_name,
    "location": location,
    "service_latitude": service_latitude,
    "service_longitude": service_longitude,
    "business_description": business_description,
    "cost": cost,


  };
}
