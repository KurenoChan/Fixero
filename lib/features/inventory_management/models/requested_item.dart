class RequestedItem {
  final String requestItemID;
  final String requestID;
  final String itemID;
  final int quantityRequested;
  final String status; // "Pending" | "Received" | "Not Processed"
  final String? remark;

  RequestedItem({
    required this.requestItemID,
    required this.requestID,
    required this.itemID,
    required this.quantityRequested,
    this.status = "Pending",
    this.remark,
  });

  // ✅ copyWith method
  RequestedItem copyWith({
    String? requestItemID,
    String? requestID,
    String? itemID,
    int? quantityRequested,
    String? status,
    String? remark,
  }) {
    return RequestedItem(
      requestItemID: requestItemID ?? this.requestItemID,
      requestID: requestID ?? this.requestID,
      itemID: itemID ?? this.itemID,
      quantityRequested: quantityRequested ?? this.quantityRequested,
      status: status ?? this.status,
      remark: remark ?? this.remark,
    );
  }

  // ✅ fromMap
  factory RequestedItem.fromMap(Map<String, dynamic> map, String requestItemID) {
    return RequestedItem(
      requestItemID: requestItemID,
      requestID: map["requestID"] ?? "",
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
      "requestID": requestID,
      "itemID": itemID,
      "quantityRequested": quantityRequested,
      "status": status,
      "remark": remark,
    };
  }
}