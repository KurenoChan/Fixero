import 'package:firebase_database/firebase_database.dart';

class ServiceJob {
  final String jobID;
  final String plateNo;
  final String jobServiceType;
  final String jobDescription;
  final String jobStatus;
  final String scheduledDate;
  final String scheduledTime;
  final int? estimatedDuration;
  final String? managedBy;
  final String? mechanicID;
  final DateTime sortStamp;

  const ServiceJob({
    required this.jobID,
    required this.plateNo,
    required this.jobServiceType,
    required this.jobDescription,
    required this.jobStatus,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.sortStamp,
    this.estimatedDuration,
    this.managedBy,
    this.mechanicID,
  });

  /// Build from a map, using `fallbackKey` as the jobID if not found in map.
  factory ServiceJob.fromMap(Map<dynamic, dynamic> map, {String? fallbackKey}) {
    String s(dynamic v) => (v ?? '').toString();

    final id = s(map['jobID'] ?? map['jobId'] ?? map['id'] ?? fallbackKey);

    return ServiceJob(
      jobID: id,
      plateNo: s(map['plateNo']),
      jobServiceType: s(map['jobServiceType']),
      jobDescription: s(map['jobDescription']),
      jobStatus: s(map['jobStatus']),
      scheduledDate: s(map['scheduledDate']),
      scheduledTime: s(map['scheduledTime']),
      estimatedDuration:
          (map['estimatedDuration'] is num) ? (map['estimatedDuration'] as num).toInt() : null,
      managedBy: s(map['managedBy']).isEmpty ? null : s(map['managedBy']),
      mechanicID: s(map['mechanicID']).isEmpty ? null : s(map['mechanicID']),
      sortStamp: _parseStamp(map),
    );
  }

  /// Build directly from a snapshot, using the node key as fallback id.
  factory ServiceJob.fromSnapshot(DataSnapshot snap) {
    final raw = snap.value;
    final map = (raw is Map) ? Map<dynamic, dynamic>.from(raw) : <dynamic, dynamic>{};
    return ServiceJob.fromMap(map, fallbackKey: snap.key);
  }

  Map<String, dynamic> toMap() => {
        'jobID': jobID,
        'plateNo': plateNo,
        'jobServiceType': jobServiceType,
        'jobDescription': jobDescription,
        'jobStatus': jobStatus,
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'estimatedDuration': estimatedDuration,
        'managedBy': managedBy,
        'mechanicID': mechanicID,
        'sortStamp': sortStamp.millisecondsSinceEpoch,
      };

  static DateTime _parseStamp(Map<dynamic, dynamic> m) {
    // 1) Try scheduledDate + scheduledTime
    final d = (m['scheduledDate'] ?? '').toString();
    final t = (m['scheduledTime'] ?? '').toString();
    if (d.isNotEmpty) {
      final iso = t.isEmpty ? d : '${d}T$t';
      final parsed = DateTime.tryParse(iso);
      if (parsed != null) return parsed;
    }
    // 2) Try createdAt/sortStamp
    final created = m['createdAt'] ?? m['sortStamp'];
    if (created is int) return DateTime.fromMillisecondsSinceEpoch(created);
    if (created is num) return DateTime.fromMillisecondsSinceEpoch(created.toInt());
    if (created is String) {
      final n = int.tryParse(created);
      if (n != null) return DateTime.fromMillisecondsSinceEpoch(n);
      final parsed = DateTime.tryParse(created);
      if (parsed != null) return parsed;
    }
    // 3) Fallback to epoch
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
