class RestockRequest {
  final String requestId;
  final DateTime requestDateTime;
  final String requestBy; // Workshop Manager UID
  final String status; // "Pending" | "Approved" | "Cancelled"
  final String? approvedBy;
  final String? cancelledBy;
  final DateTime? approvedDate;
  final DateTime? cancelledDate;
  final String? orderNo;

  RestockRequest({
    required this.requestId,
    required this.requestDateTime,
    required this.requestBy,
    this.status = "Pending",
    this.approvedBy,
    this.cancelledBy,
    this.approvedDate,
    this.cancelledDate,
    this.orderNo,
  });

  // To convert Firebase JSON into Item
  factory RestockRequest.fromMap(Map<String, dynamic> map, String requestId) {
    final String? dateStr = map["requestDate"];
    final String? timeStr = map["requestTime"];
    DateTime? parsedDateTime;

    if (dateStr != null && timeStr != null) {
      // Combine date and time properly
      parsedDateTime = DateTime.tryParse("$dateStr $timeStr");
    }

    return RestockRequest(
      requestId: requestId,
      requestDateTime: parsedDateTime ?? DateTime.now(),
      requestBy: map["requestBy"] ?? "",
      status: map["status"] ?? "Pending",
      approvedBy: map["approvedBy"],
      cancelledBy: map["cancelledBy"],
      approvedDate: map["approvedDate"] != null
          ? DateTime.tryParse(map["approvedDate"])
          : null,
      cancelledDate: map["cancelledDate"] != null
          ? DateTime.tryParse(map["cancelledDate"])
          : null,
      orderNo: map["orderNo"],
    );
  }

  // To convert Item into Firebase JSON
  Map<String, dynamic> toMap() {
    return {
      "requestDate": requestDateTime.toIso8601String().split("T").first,
      "requestTime": requestDateTime
          .toIso8601String()
          .split("T")
          .last
          .split('.')
          .first,
      "status": status,
      "requestBy": requestBy,
      "approvedBy": approvedBy,
      "cancelledBy": cancelledBy,
      "approvedDate": approvedDate?.toIso8601String(),
      "cancelledDate": cancelledDate?.toIso8601String(),
      "orderNo": orderNo,
    };
  }
}
