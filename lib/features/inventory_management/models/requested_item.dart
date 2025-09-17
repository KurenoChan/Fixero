class RequestedItem {
  final String requestItemId;
  final String requestId;
  final String itemID;
  final int quantityRequested;
  final String status; // "Pending" | "Received" | "Not Processed"
  final String? remark;

  RequestedItem({
    required this.requestItemId,
    required this.requestId,
    required this.itemID,
    required this.quantityRequested,
    this.status = "Pending",
    this.remark,
  });

  // ✅ copyWith method
  RequestedItem copyWith({
    String? requestItemId,
    String? requestId,
    String? itemID,
    int? quantityRequested,
    String? status,
    String? remark,
  }) {
    return RequestedItem(
      requestItemId: requestItemId ?? this.requestItemId,
      requestId: requestId ?? this.requestId,
      itemID: itemID ?? this.itemID,
      quantityRequested: quantityRequested ?? this.quantityRequested,
      status: status ?? this.status,
      remark: remark ?? this.remark,
    );
  }

  // ✅ fromMap
  factory RequestedItem.fromMap(Map<String, dynamic> map, String requestItemId) {
    return RequestedItem(
      requestItemId: requestItemId,
      requestId: map["requestID"] ?? "",
      itemID: map["itemID"] ?? "",
      quantityRequested: map["quantityRequested"] is int
          ? map["quantityRequested"]
          : int.tryParse(map["quantityRequested"].toString()) ?? 0,
      status: map["status"] ?? "Pending",
      remark: map["remark"],
    );
  }

  // ✅ toMap
  Map<String, dynamic> toMap() {
    return {
      "requestID": requestId,
      "itemID": itemID,
      "quantityRequested": quantityRequested,
      "status": status,
      "remark": remark,
    };
  }
}