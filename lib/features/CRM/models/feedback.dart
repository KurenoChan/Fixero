class FeedbackModel {
  final String feedbackID;
  final String feedbackType;
  final String comment;
  final int completionEfficiency;
  final String date;
  final int engineeringAttitude;
  final String jobID;
  final int serviceQuality;
  String status;      // mutable
  String seenStatus;  // mutable

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
  });

  factory FeedbackModel.fromMap(String id, Map<String, dynamic> data) {
    return FeedbackModel(
      feedbackID: id,
      feedbackType: data["feedbackType"] ?? "General",
      comment: data["comment"] ?? "",
      completionEfficiency: data["completionEfficiency"] ?? 0,
      date: data["date"] ?? "-",
      engineeringAttitude: data["engineeringAttitude"] ?? 0,
      jobID: data["jobID"] ?? "",
      serviceQuality: data["serviceQuality"] ?? 0,
      status: data["status"] ?? "Open",
      seenStatus: data["seenStatus"] ?? "Seen",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "feedbackType": feedbackType,
      "comment": comment,
      "completionEfficiency": completionEfficiency,
      "date": date,
      "engineeringAttitude": engineeringAttitude,
      "jobID": jobID,
      "serviceQuality": serviceQuality,
      "status": status,
      "seenStatus": seenStatus,
    };
  }
}
