class ReviewsResponseData {
  int? id;
  int? customerId;
  int? vendorId;
  String? subject;
  String? detail;
  int? ratings;
  String? tags;
  String? reviewDate;
  Customer? customer;

  ReviewsResponseData({
    this.id,
    this.customerId,
    this.vendorId,
    this.subject,
    this.detail,
    this.ratings,
    this.tags,
    this.reviewDate,
    this.customer,
  });

  factory ReviewsResponseData.fromJson(Map<String, dynamic> json) {
    return ReviewsResponseData(
      id: json['id'],
      customerId: json['customer_id'],
      vendorId: json['vendor_id'],
      subject: json['subject'],
      detail: json['detail'],
      ratings: json['ratings'],
      tags: json['tags'],
      reviewDate: json['review_date'],
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'vendor_id': vendorId,
      'subject': subject,
      'detail': detail,
      'ratings': ratings,
      'tags': tags,
      'review_date': reviewDate,
      'customer': customer?.toJson(),
    };
  }
}

class Customer {
  String? property1;
  String? property2;

  Customer({
    this.property1,
    this.property2,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      property1: json['property1'],
      property2: json['property2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property1': property1,
      'property2': property2,
    };
  }
}
