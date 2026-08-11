class CreateAppointmentResponse {
  CreateAppointmentResponse({
    this.customer_address,
    this.customer_id,
    this.customer_latitude,
    this.customer_longitude,
    this.order_amount,
    this.order_datetime,
    this.order_no,
    this.order_status,
    this.payment_status,
    this.vendor_id,
    this.message,

  });

  String? customer_address;
  int? customer_id;
  String? customer_latitude;
  String? customer_longitude;
  double? order_amount;
  String? order_datetime;
  String? order_no;
  String? order_status;
  String? payment_status;
  int? vendor_id;
  String? message;


  factory CreateAppointmentResponse.fromJson(Map<String, dynamic> json) =>
      CreateAppointmentResponse(
        customer_address: json["customer_address"],
        customer_id: json["customer_id"],
        customer_latitude: json["customer_latitude"],
        customer_longitude: json["customer_longitude"],
        order_amount: json["order_amount"],
        order_datetime: json["order_datetime"],
        order_no: json["order_no"],
        order_status: json["order_status"],
        payment_status: json["payment_status"],
        vendor_id: json["vendor_id"],
        message: json["message"],

      );

  Map<String, dynamic> toJson() => {
        "customer_address": customer_address,
        "customer_id": customer_id,
        "customer_latitude": customer_latitude,
        "customer_longitude": customer_longitude,
        "order_amount": order_amount,
        "order_datetime": order_datetime,
        "order_no": order_no,
        "order_status": order_status,
        "payment_status": payment_status,
        "vendor_id": vendor_id,
        "message": message,

  };
}
