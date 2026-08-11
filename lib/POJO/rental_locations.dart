import 'package:TrendTodayCustomer/POJO/rental_location_details.dart';

class RentalLocations {
  RentalLocations({
    this.rental_address,


  });

  List<RentalLocationsDetails>? rental_address;


  factory RentalLocations.fromJson(Map<String, dynamic> json) => RentalLocations(


    rental_address: List<RentalLocationsDetails>.from(json["rental_address"]), // Parse services as List<String>


  );

  Map<String, dynamic> toJson() => {
    "rental_address": rental_address,
  };
}
