class LocationResponseData {
  LocationResponseData({
    this.service_city,
    this.service_latitude,
    this.service_longitude,

  });

  String? service_city;
  String? service_latitude;
  String? service_longitude;

  factory LocationResponseData.fromJson(Map<String, dynamic> json) => LocationResponseData(
    service_city: json["service_city"],
    service_latitude: json["service_latitude"],
    service_longitude: json["service_longitude"],
  );

  Map<String, dynamic> toJson() => {
    "service_city": service_city,
    "service_latitude": service_latitude,
    "service_longitude": service_longitude,

  };
}
