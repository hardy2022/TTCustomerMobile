
class OrderStagesDataDetailsResponse {

  String? status;
  String? time;
  bool? passed;


  OrderStagesDataDetailsResponse({
    this.status,
    this.time,
    this.passed,

  });

  factory OrderStagesDataDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderStagesDataDetailsResponse(

      status: json["status"],
      time: json["time"],
      passed: json["passed"],

    );
  }

  Map<String, dynamic> toJson() {
    return {

      "status": status,
      "time": time,
      "passed": passed,
    };
  }
}