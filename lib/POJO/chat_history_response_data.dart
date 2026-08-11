

class ChatHistoryResponseData {

  String? sender_name;
  String? sender;
  String? message;
  String? timestamp;

  ChatHistoryResponseData({
    this.sender_name,
    this.sender,
    this.message,
    this.timestamp,



  });

  factory ChatHistoryResponseData.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponseData(

      sender_name: json["sender_name"],
      sender: json["sender"],
      message: json["message"],
      timestamp: json["timestamp"],

    );
  }

  Map<String, dynamic> toJson() {
    return {

      "sender_name": sender_name,
      "sender": sender,
      "message": message,
      "timestamp": timestamp,


    };
  }
}
