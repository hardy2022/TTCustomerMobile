class ResetPassword {
  String? reset_url;
  String? token;
  String? description;
  int? code;



  ResetPassword({
    this.reset_url,
    this.token,
    this.description,
    this.code,


  });

  factory ResetPassword.fromJson(Map<String, dynamic> json) {
    return ResetPassword(
      reset_url: json['reset_url'],
      description: json['description'],
      code: json['code'],
      token: json['token'],



    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reset_url': reset_url,
      'description': description,
      'code': code,
      'token': token,


    };
  }
}

