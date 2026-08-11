
import 'order_stages_data_details_response.dart';

class OrderStagesDataResponse {

  String? vendor_name;
  String? profile_image;
  String? service_image;
  int? total_services;
  double? star_ratings;
  int? total_reviews;
  String? appointment_date;
  String? appointment_time;
  List<OrderStagesDataDetailsResponse>? appointment_stages;


  OrderStagesDataResponse({
    this.vendor_name,
    this.profile_image,
    this.service_image,
    this.total_services,
    this.star_ratings,
    this.total_reviews,
    this.appointment_stages,
    this.appointment_date,
    this.appointment_time,


  });

  factory OrderStagesDataResponse.fromJson(Map<String, dynamic> json) {
    return OrderStagesDataResponse(

      vendor_name: json["vendor_name"],
      profile_image: json["profile_image"],
      service_image: json["service_image"],
      total_services: json["total_services"],
      star_ratings: json["star_ratings"],
      total_reviews: json["total_reviews"],
      appointment_date: json["appointment_date"],
      appointment_time: json["appointment_time"],
      appointment_stages: (json["appointment_stages"] as List<dynamic>).map((item) => OrderStagesDataDetailsResponse.fromJson(item)).toList(),
// Safely parse appointment_stages
    );
  }

  Map<String, dynamic> toJson() {
    return {

      "vendor_name": vendor_name,
      "profile_image": profile_image,
      "service_image": service_image,
      "total_services": total_services,
      "star_ratings": star_ratings,
      "total_reviews": total_reviews,
      "appointment_stages": appointment_stages,
      "appointment_date": appointment_date,
      "appointment_time": appointment_time,


    };
  }
}
