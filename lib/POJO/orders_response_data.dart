class OrdersResponseData {
  OrdersResponseData({
    this.id,
    this.order_id,
    this.customer,
    this.vendor,
    this.customer_id,
    this.vendor_id,
    this.address,
    this.status,
    this.order_amount,
    this.date,
    this.time,
    this.duration,
    this.image,
    this.profile_image,
    this.services,
    this.business_name,
    this.professional_name,
  });

  int? id;
  String? order_id;
  String? customer;
  String? vendor;
  int? customer_id;
  int? vendor_id;
  String? address;
  String? status;
  double? order_amount;
  String? date;
  String? time;
  String? duration;
  String? image;
  String? profile_image;
  List<String>? services;
  String? business_name;
  String? professional_name;

  factory OrdersResponseData.fromJson(Map<String, dynamic> json) =>
      OrdersResponseData(
        id: json["id"],
        order_id: json["order_id"],
        customer: json["customer"],
        vendor: json["vendor"],
        customer_id: json["customer_id"],
        vendor_id: json["vendor_id"],
        address: json["address"],
        status: json["status"],
        order_amount: json["order_amount"],
        date: json["date"],
        time: json["time"],
        duration: json["duration"],
        image: json["image"],
        profile_image: json["profile_image"],
        services: json["services"] != null
            ? List<String>.from(json["services"].map((x) => x.toString()))
            : null,
        business_name: json["business_name"],
        professional_name: json["professional_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": order_id,
        "customer": customer,
        "vendor": vendor,
        "customer_id": customer_id,
        "vendor_id": vendor_id,
        "address": address,
        "status": status,
        "order_amount": order_amount,
        "date": date,
        "time": time,
        "duration": duration,
        "image": image,
        "profile_image": profile_image,
        "services": services,
        "business_name": business_name,
        "professional_name": professional_name,
      };
}
