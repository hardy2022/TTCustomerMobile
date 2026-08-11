

class StartChatResponse {

  String? chat_id;
  String? vendor_id;
  String? customer_id;

  StartChatResponse({
    this.chat_id,
    this.vendor_id,
    this.customer_id,


  });

  factory StartChatResponse.fromJson(Map<String, dynamic> json) {
    return StartChatResponse(

      chat_id: json["chat_id"],
      vendor_id: json["vendor_id"],
      customer_id: json["customer_id"],

    );
  }

  Map<String, dynamic> toJson() {
    return {

      "chat_id": chat_id,
      "vendor_id": vendor_id,
      "customer_id": customer_id,

    };
  }
}
