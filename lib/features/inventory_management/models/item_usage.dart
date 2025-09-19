class ItemUsage {
  final String itemUsageNo;
  final int? quantityUsed;
  final String usageDate;
  final String usageTime;
  final String? remark;
  final String jobID;
  final String itemID;

  ItemUsage({
    required this.itemUsageNo,
    this.quantityUsed,
    required this.usageDate,
    required this.usageTime,
    this.remark,
    required this.jobID,
    required this.itemID,
  });

  ItemUsage copyWith({
    String? itemUsageNo,
    int? quantityUsed,
    String? usageDate,
    String? usageTime,
    String? remark,
    String? jobID,
    String? itemID,
  }) {
    return ItemUsage(
      itemUsageNo: itemUsageNo ?? this.itemUsageNo,
      quantityUsed: quantityUsed ?? this.quantityUsed,
      usageDate: usageDate ?? this.usageDate,
      usageTime: usageTime ?? this.usageTime,
      remark: remark ?? this.remark,
      jobID: jobID ?? this.jobID,
      itemID: itemID ?? this.itemID,
    );
  }

  // To conver Firebase JSON into ItemUsage
  factory ItemUsage.fromMap(Map<dynamic, dynamic> map, String id) {
    return ItemUsage(
      itemUsageNo: id,
      quantityUsed: map['quantityUsed'],
      usageDate: map['usageDate'],
      usageTime: map['usageTime'],
      remark: map['remark'],
      jobID: map['jobID'],
      itemID: map['itemID'],
    );
  }

  // To convert ItemUsage into Firebase JSON
  Map<String, dynamic> toMap() {
    return {
      'quantityUsed': quantityUsed,
      'usageDate': usageDate,
      'usageTime': usageTime,
      'remark': remark,
      'jobID': jobID,
      'itemID': itemID,
    };
  }
}
