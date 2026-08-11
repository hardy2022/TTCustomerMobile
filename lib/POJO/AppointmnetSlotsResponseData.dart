class AvailableSlotResponseData {
  AvailableSlotResponseData({
    this.all_slots,
    this.booked_slots,
    this.messages,


  });

  List<String>? all_slots;
  List<String>? booked_slots;
  String? messages;


  factory AvailableSlotResponseData.fromJson(Map<String, dynamic> json) => AvailableSlotResponseData(


    all_slots: List<String>.from(json["all_slots"]), // Parse services as List<String>
    booked_slots: List<String>.from(json["booked_slots"]), // Parse services as List<String>
    messages: json["messages"],


  );

  Map<String, dynamic> toJson() => {
    "all_slots": all_slots,
    "booked_slots": booked_slots,
    "messages": messages,


  };
}
