class Order {
  final String orderNo;
  final DateTime orderDate;
  final DateTime? arrivalDate;
  final int? rating;      // optional, 1-5
  final String? feedback; // optional
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
      "orderNo": orderNo,
      "orderDate": orderDate.toIso8601String(),
      "arrivalDate": arrivalDate?.toIso8601String(),
      "rating": rating,
      "feedback": feedback ?? "",
      "supplierID": supplierID,
    };
  }

  factory Order.fromMap(Map<dynamic, dynamic> map, String id) {
    return Order(
      orderNo: id,
      orderDate: DateTime.parse(map["orderDate"] ?? DateTime.now().toIso8601String()),
      arrivalDate: map["arrivalDate"] != null ? DateTime.parse(map["arrivalDate"]) : null,
      rating: map["rating"],
      feedback: map["feedback"],
      supplierID: map["supplierID"] ?? "",
    );
  }
}
