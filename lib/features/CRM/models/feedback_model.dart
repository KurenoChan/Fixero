class FeedbackModel {
  final String feedbackID;
  String feedbackType;
  String comment;
  int completionEfficiency;
  String date;
  int engineeringAttitude;
  String jobID;
  int serviceQuality;
  String status;
  String seenStatus;

  // Enriched fields
  String? customerId;     // 🔹 add this
  String? customerName;
  String? carModel;
  String? serviceType;

  FeedbackModel({
    required this.feedbackID,
    required this.feedbackType,
    required this.comment,
    required this.completionEfficiency,
    required this.date,
    required this.engineeringAttitude,
    required this.jobID,
    required this.serviceQuality,
    required this.status,
    required this.seenStatus,
    this.customerId,        // new
    this.customerName,
    this.carModel,
    this.serviceType,
  });

  factory FeedbackModel.fromMap(String id, Map<String, dynamic> data) {
    return FeedbackModel(
      feedbackID: id,
      feedbackType: data['feedbackType'] ?? 'General',
      comment: data['comment'] ?? '',
      completionEfficiency: (data['completionEfficiency'] ?? 0) as int,
      date: data['date'] ?? '-',
      engineeringAttitude: (data['engineeringAttitude'] ?? 0) as int,
      jobID: data['jobID'] ?? '',
      serviceQuality: (data['serviceQuality'] ?? 0) as int,
      status: data['status'] ?? 'Open',
      seenStatus: data['seenStatus'] ?? 'Seen',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'feedbackType': feedbackType,
      'comment': comment,
      'completionEfficiency': completionEfficiency,
      'date': date,
      'engineeringAttitude': engineeringAttitude,
      'jobID': jobID,
      'serviceQuality': serviceQuality,
      'status': status,
      'seenStatus': seenStatus,
      if (customerId != null) 'customerId': customerId,
      if (customerName != null) 'customerName': customerName,
      if (carModel != null) 'carModel': carModel,
      if (serviceType != null) 'serviceType': serviceType,
    };
  }


}
