class AppointmentInputData {
  AppointmentInputData({
    this.vendor_id,
    this.service_location,
    this.service_details,
    this.vendor_latitude,
    this.vendor_longitude,


  });

  String? vendor_id;
  String? service_location;
  String? vendor_latitude;
  String? vendor_longitude;
  List<ServiceDetails>? service_details;

  factory AppointmentInputData.fromJson(Map<String, dynamic> json) =>
      AppointmentInputData(
        vendor_id: json["vendor_id"],
        service_location: json["service_location"],
        vendor_latitude: json["vendor_latitude"],
        vendor_longitude: json["vendor_longitude"],
        service_details: json["service_details"],
      );

  Map<String, dynamic> toJson() => {
        "vendor_id": vendor_id,
        "service_location": service_location,
        "service_details": service_details,
    "vendor_latitude": vendor_latitude,
    "vendor_longitude": vendor_longitude,

  };
}

class ServiceDetails {
  ServiceDetails({
    this.service_id,
    this.service_date,
    this.service_time,
    this.quantity,
  });

  String? service_id;
  String? service_date;
  String? service_time;
  String? quantity;

  factory ServiceDetails.fromJson(Map<String, dynamic> json) => ServiceDetails(
        service_id: json["service_id"],
        service_date: json["service_date"],
        service_time: json["service_time"],


    quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "service_id": service_id,
        "service_date": service_date,
        "service_time": service_time,
        "quantity": quantity,
      };
}
