// rental_location_details.dart
class RentalLocationsDetails {
  final String? address;
  final String? latitude;   // keep as String if your API returns strings
  final String? longitude;

  RentalLocationsDetails({this.address, this.latitude, this.longitude});

  factory RentalLocationsDetails.fromJson(Map<String, dynamic> json) {
    return RentalLocationsDetails(
      address: json['address'] as String?,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}
