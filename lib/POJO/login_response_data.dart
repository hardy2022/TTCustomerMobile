class LoginResponseData {
  LoginResponseData({
    this.access_token,
    this.refresh_token,
    this.description,
    this.message,
  });

  String? access_token;
  String? refresh_token;
  String? description;
  String? message;

  factory LoginResponseData.fromJson(Map<String, dynamic> json) => LoginResponseData(
    access_token: json["access_token"],
    refresh_token: json["refresh_token"],
    description: json["description"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "access_token": access_token,
    "refresh_token": refresh_token,
    "description": description,
    "message": message,
  };
}
