// models/job_model.dart
class Job {
  final String jobID;
  String jobServiceType;
  String jobDescription;
  String jobStatus;
  String scheduledDate;
  String scheduledTime;
  int estimatedDuration;
  String createdAt;
  String mechanicID;
  String plateNo;
  String managedBy;

  Job({
    required this.jobID,
    required this.jobServiceType,
    required this.jobDescription,
    required this.jobStatus,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.estimatedDuration,
    required this.createdAt,
    required this.mechanicID,
    required this.plateNo,
    required this.managedBy,
  });

  factory Job.fromMap(String id, Map<String, dynamic> data) {
    return Job(
      jobID: id,
      jobServiceType: data['jobServiceType'] ?? '',
      jobDescription: data['jobDescription'] ?? '',
      jobStatus: data['jobStatus'] ?? '',
      scheduledDate: data['scheduledDate'] ?? '',
      scheduledTime: data['scheduledTime'] ?? '',
      estimatedDuration: data['estimatedDuration'] ?? 0,
      createdAt: data['createdAt'] ?? '',
      mechanicID: data['mechanicID'] ?? '',
      plateNo: data['plateNo'] ?? '',
      managedBy: data['managedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'jobServiceType': jobServiceType,
    'jobDescription': jobDescription,
    'jobStatus': jobStatus,
    'scheduledDate': scheduledDate,
    'scheduledTime': scheduledTime,
    'estimatedDuration': estimatedDuration,
    'createdAt': createdAt,
    'mechanicID': mechanicID,
    'plateNo': plateNo,
    'managedBy': managedBy,
  };
}
