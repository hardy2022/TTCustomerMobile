class ServicesResponseData {
  ServicesResponseData({
    this.id,
    this.name,
    this.description,
    this.tags,
    this.cost,
    this.is_active,
  });


  String? id;
  String? name;
  String? description;
  String? tags;
  double? cost;
  bool? is_active;

  // Parsing a single service object
  factory ServicesResponseData.fromJson(Map<String, dynamic> json) => ServicesResponseData(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    tags: json["tags"],
    cost: json["cost"],
    is_active: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "tags": tags,
    "cost": cost,
    "is_active": is_active,
  };
}
