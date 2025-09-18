// models/job_model.dart
class Job {
  final String jobId;
  final String plateNumber;
  final String carModel;
  final String serviceType;
  final String serviceDate;
  final String mechanicName;
  final String customerName;
  final String status;

  Job({
    required this.jobId,
    required this.plateNumber,
    required this.carModel,
    required this.serviceType,
    required this.serviceDate,
    required this.mechanicName,
    required this.customerName,
    required this.status,
  });

  factory Job.fromMap(Map<dynamic, dynamic> map, String id) {
    return Job(
      jobId: id,
      plateNumber: map['plateNumber'] ?? '',
      carModel: map['carModel'] ?? '',
      serviceType: map['serviceType'] ?? '',
      serviceDate: map['serviceDate'] ?? '',
      mechanicName: map['mechanicName'] ?? '',
      customerName: map['customerName'] ?? '',
      status: map['status'] ?? 'Unknown',
    );
  }
}