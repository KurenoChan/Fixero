class RestockRequest {
  final String requestID;
  final String requestDate; // yyyy-MM-dd
  final String requestTime; // HH:mm:ss
  final String requestBy; // Workshop Manager UID
  final String status; // "Pending" | "Approved" | "Rejected"
  final String? approvedBy;
  final String? rejectedBy;
  final String? approvedDate; // yyyy-MM-dd
  final String? rejectedDate; // yyyy-MM-dd
  final String? orderNo;

  RestockRequest({
    required this.requestID,
    required this.requestDate,
    required this.requestTime,
    required this.requestBy,
    this.status = "Pending",
    this.approvedBy,
    this.rejectedBy,
    this.approvedDate,
    this.rejectedDate,
    this.orderNo,
  });

  // ✅ copyWith
  RestockRequest copyWith({
    String? requestID,
    String? requestDate,
    String? requestTime,
    String? requestBy,
    String? status,
    String? approvedBy,
    String? rejectedBy,
    String? approvedDate,
    String? rejectedDate,
    String? orderNo,
  }) {
    return RestockRequest(
      requestID: requestID ?? this.requestID,
      requestDate: requestDate ?? this.requestDate,
      requestTime: requestTime ?? this.requestTime,
      requestBy: requestBy ?? this.requestBy,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      approvedDate: approvedDate ?? this.approvedDate,
      rejectedDate: rejectedDate ?? this.rejectedDate,
      orderNo: orderNo ?? this.orderNo,
    );
  }

  // ✅ fromMap
  factory RestockRequest.fromMap(Map<String, dynamic> map, String requestID) {
    return RestockRequest(
      requestID: requestID,
      requestDate: map["requestDate"],
      requestTime: map["requestTime"],
      requestBy: map["requestBy"] ?? "",
      status: map["status"] ?? "Pending",
      approvedBy: map["approvedBy"],
      rejectedBy: map["rejectedBy"],
      approvedDate: map["approvedDate"],
      rejectedDate: map["rejectedDate"],
      orderNo: map["orderNo"],
    );
  }

  // ✅ toMap
  Map<String, dynamic> toMap() {
    return {
      "requestDate": requestDate,
      "requestTime": requestTime,
      "status": status,
      "requestBy": requestBy,
      "approvedBy": approvedBy,
      "rejectedBy": rejectedBy,
      "approvedDate": approvedDate,
      "rejectedDate": rejectedDate,
      "orderNo": orderNo,
    };
  }
}
