class Order {
  final String orderNo;
  final String orderDate;
  final String? arrivalDate;
  final int? rating;
  final String? feedback;
  final String supplierID;

  Order({
    required this.orderNo,
    required this.orderDate,
    this.arrivalDate,
    this.rating,
    this.feedback,
    required this.supplierID,
  });

  Map<String, dynamic> toMap() {
    return {
      "orderDate": orderDate,
      "arrivalDate": arrivalDate,
      "rating": rating,
      "feedback": feedback,
      "supplierID": supplierID,
    };
  }

  factory Order.fromMap(Map<dynamic, dynamic> map, String id) {
    return Order(
      orderNo: id,
      orderDate: map["orderDate"],
      arrivalDate: map["arrivalDate"],
      rating: map["rating"],
      feedback: map["feedback"],
      supplierID: map["supplierID"],
    );
  }
  Order copyWith({
    String? orderNo,
    String? orderDate,
    String? arrivalDate,
    int? rating,
    String? feedback,
    String? supplierID,
  }) {
    return Order(
      orderNo: orderNo ?? this.orderNo,
      orderDate: orderDate ?? this.orderDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      supplierID: supplierID ?? this.supplierID,
    );
  }
}
