
import 'package:TrendTodayCustomer/POJO/rental_location_details.dart';

class ProfileDataResponse {
  ProfileDataResponse({

    this.message,
    this.success,
    this.data,
    this.birth_date,
    this.created,
    this.device_token,
    this.entity,
    this.first_name,
    this.id,
    this.is_active,
    this.last_name,
    this.location,
    this.mobile_no,
    this.profile_image,
    this.username,
    this.user,
    this.business_name,
    this.business_description,
    this.logo,
    this.vendor_status,
    this.cost,
    this.professional_name,
    this.service_hours,
    this.service_location,
    this.rental_address,



  });


  String? message;
  String? success;
  ProfileDataResponseDetails?  data;
  String? birth_date;
  String? created;
  String? device_token;
  String? entity;
  String? first_name;
  String? id;
  String? is_active;
  String? last_name;
  String? location;
  String? mobile_no;
  String? profile_image;
  String? username;
  UserData? user;
  String? business_name;
  String? professional_name;
  String? business_description;
  String? logo;
  String? vendor_status;
  String? cost;
  List<ServiceHoursDetails>? service_hours;
  ServiceLocationDetails? service_location;
  List<RentalLocationsDetails>? rental_address;



  factory ProfileDataResponse.fromJson(Map<String, dynamic> json) => ProfileDataResponse(

    message: json["message"],
    success: json["success"],
    birth_date: json["birth_date"],
    created: json["created"],
    device_token: json["device_token"],
    entity: json["entity"],
    first_name: json["first_name"],
    id: json["id"],
    is_active: json["is_active"],
    last_name: json["last_name"],
    location: json["location"],
    mobile_no: json["mobile_no"],
    profile_image: json["profile_image"],
    username: json["username"],
    user: json["user"] != null ? UserData.fromJson(json["user"]) : null, // No need to use map
    business_name: json["business_name"],
    business_description: json["business_description"],
    logo: json["logo"],
    vendor_status: json["vendor_status"],
    cost: json["cost"],
    professional_name: json["professional_name"],
    service_hours: (json['service_hours'] as List<dynamic>?)
        ?.map((item) => ServiceHoursDetails.fromJson(item as Map<String, dynamic>))
        .toList(),
    service_location: json["service_location"] != null ? ServiceLocationDetails.fromJson(json["service_location"]) : null, // No need to use map
   // rental_address: List<RentalLocationsDetails>.from(json["rental_address"]), // Parse services as List<String>

    rental_address: (json['rental_address'] as List<dynamic>?)
        ?.map((e) => RentalLocationsDetails.fromJson(e as Map<String, dynamic>))
        .toList(),

  );

  Map<String, dynamic> toJson() => {

    "message": message,
    "success": success,
    "data": data,
    "birth_date": birth_date,
    "created": created,
    "device_token": device_token,
    "entity": entity,
    "first_name": first_name,
    "id": id,
    "is_active": is_active,
    "last_name": last_name,
    "location": location,
    "mobile_no": mobile_no,
    "profile_image": profile_image,
    "username": username,
    "user": user,
    "business_name": business_name,
    "business_description": business_description,
    "logo": logo,
    "vendor_status": vendor_status,
    "cost": cost,
    "professional_name": professional_name,
    "service_hours": service_hours,
    "service_location": service_location,
    "rental_address": rental_address?.map((e) => e.toJson()).toList(),



  };
}

class ProfileDataResponseDetails {
  ProfileDataResponseDetails({
    this.created,
    this.first_name,
    this.id,
    this.last_name,
    this.logo,
    this.mobile_no,
    this.otp,
  });

  String? created;
  String? first_name;
  String? id;
  String? last_name;
  String? logo;
  String? mobile_no;
  String? otp;



  factory ProfileDataResponseDetails.fromJson(Map<String, dynamic> json) => ProfileDataResponseDetails(
    created: json["created"],
    first_name: json["first_name"],
    id: json["id"],
    last_name: json["last_name"],
    logo: json["logo"],
    mobile_no: json["mobile_no"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "created": created,
    "first_name": first_name,
    "id": id,
    "last_name": last_name,
    "logo": logo,
    "mobile_no": mobile_no,
    "otp": otp,
  };
}



class UserData {
  String? about_me;
  String? first_name;
  String? last_name;
  String? mobile_no;
  String? profile_image;

  UserData({
    this.about_me,
    this.first_name,
    this.last_name,
    this.mobile_no,
    this.profile_image,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      about_me: json["about_me"],
      first_name: json["first_name"],
      last_name: json["last_name"],
      mobile_no: json["mobile_no"],
      profile_image: json["profile_image"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "about_me": about_me,
      "first_name": first_name,
      "last_name": last_name,
      "mobile_no": mobile_no,
      "profile_image": profile_image,
    };
  }
}


class ServiceHoursDetails {
  String? day;
  String? from_time;
  String? to_time;

  ServiceHoursDetails({
    this.day,
    this.from_time,
    this.to_time,

  });

  factory ServiceHoursDetails.fromJson(Map<String, dynamic> json) {
    return ServiceHoursDetails(
      day: json["day"],
      from_time: json["from_time"],
      to_time: json["to_time"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "day": day,
      "from_time": from_time,
      "to_time": to_time,
    };
  }
}


class ServiceLocationDetails {
  String? address1;
  String? address2;
  String? service_latitude;
  String? service_longitude;


  ServiceLocationDetails({
    this.address1,
    this.address2,
    this.service_latitude,
    this.service_longitude,


  });

  factory ServiceLocationDetails.fromJson(Map<String, dynamic> json) {
    return ServiceLocationDetails(
      address1: json["address1"],
      address2: json["address2"],
      service_latitude: json["service_latitude"],
      service_longitude: json["service_longitude"],

    );
  }

  Map<String, dynamic> toJson() {
    return {

      "address1": address1,
      "address2": address2,
      "service_latitude": service_latitude,
      "service_longitude": service_longitude,

    };
  }
}



