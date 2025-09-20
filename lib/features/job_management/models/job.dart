class Job {
  final String jobID;
  final String jobServiceType;
  final String jobDescription;
  final String jobStatus; // Completed, Cancelled, Ongoing, Pending
  final String scheduledDate;
  final String scheduledTime;
  final int estimatedDuration;
  final String createdAt;
  final String mechanicID;
  final String plateNo;
  final String managedBy; // Workshop Manager

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

  Job copyWith({
    String? jobID,
    String? jobServiceType,
    String? jobDescription,
    String? jobStatus,
    String? scheduledDate,
    String? scheduledTime,
    int? estimatedDuration,
    String? createdAt,
    String? mechanicID,
    String? plateNo,
    String? managedBy,
  }) {
    return Job(
      jobID: jobID ?? this.jobID,
      jobServiceType: jobServiceType ?? this.jobServiceType,
      jobDescription: jobDescription ?? this.jobDescription,
      jobStatus: jobStatus ?? this.jobStatus,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      mechanicID: mechanicID ?? this.mechanicID,
      plateNo: plateNo ?? this.plateNo,
      managedBy: managedBy ?? this.managedBy,
    );
  }

  static int _parseEstimatedDuration(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  factory Job.fromMap(Map<dynamic, dynamic> map, String id) {
    return Job(
      jobID: id,
      jobServiceType: map['jobServiceType'] ?? '',
      jobDescription: map['jobDescription'] ?? '',
      jobStatus: map['jobStatus'] ?? '',
      scheduledDate: map['scheduledDate'] ?? '',
      scheduledTime: map['scheduledTime'] ?? '',
      estimatedDuration: _parseEstimatedDuration(map['estimatedDuration']),
      createdAt: map['createdAt'] ?? '',
      mechanicID: map['mechanicID'] ?? '',
      plateNo: map['plateNo'] ?? '',
      managedBy: map['managedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
}
