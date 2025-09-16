class RequestedItem {
  final String requestItemId;
  final String requestId;
  final String itemId;
  final int quantityRequested;
  final String status; // "Pending" | "Received" | "Not Processed"
  final String? remark;

  RequestedItem({
    required this.requestItemId,
    required this.requestId,
    required this.itemId,
    required this.quantityRequested,
    this.status = "Pending",
    this.remark,
  });

  // ✅ copyWith method
  RequestedItem copyWith({
    String? requestItemId,
    String? requestId,
    String? itemId,
    int? quantityRequested,
    String? status,
    String? remark,
  }) {
    return RequestedItem(
      requestItemId: requestItemId ?? this.requestItemId,
      requestId: requestId ?? this.requestId,
      itemId: itemId ?? this.itemId,
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
      itemId: map["itemID"] ?? "",
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
      "itemID": itemId,
      "quantityRequested": quantityRequested,
      "status": status,
      "remark": remark,
    };
  }
}