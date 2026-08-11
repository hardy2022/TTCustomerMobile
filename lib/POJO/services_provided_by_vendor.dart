class ServicesProvidedByVendorResponseData {
  ServicesProvidedByVendorResponseData({
    this.vendor_service_id,
    this.service_id,
    this.service,
    this.cost,
    this.service_minutes,
    this.message,


  });

  int? vendor_service_id;
  String? all_slots;
  int? service_id;
  String? service;
  double? cost;
  double? service_minutes;
  String? message;



  factory ServicesProvidedByVendorResponseData.fromJson(Map<String, dynamic> json) =>
      ServicesProvidedByVendorResponseData(
        vendor_service_id: json["vendor_service_id"],
        service_id: json["service_id"],
        service: json["service"],
        cost: json["cost"],
        service_minutes: json["service_minutes"],
        message: json["message"],


      );

  Map<String, dynamic> toJson() =>
      {
        "vendor_service_id": vendor_service_id,
        "service_id": service_id,
        "service": service,
        "cost": cost,
        "service_minutes": service_minutes,
        "message": message,


      };
}
