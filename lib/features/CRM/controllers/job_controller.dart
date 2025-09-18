import 'package:firebase_database/firebase_database.dart';
import '../models/job_model.dart';

class JobController {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<Job?> fetchJobById(String jobId) async {
    final snap = await _dbRef.child("jobservices/jobs/$jobId").get();

    if (!snap.exists) return null;

    final data = Map<String, dynamic>.from(snap.value as Map);
    return Job.fromMap(data, jobId);
  }

  Future<List<Job>> fetchAllJobs() async {
    final snap = await _dbRef.child("jobservices/jobs").get();
    if (!snap.exists) return [];

    final data = Map<String, dynamic>.from(snap.value as Map);
    return data.entries
        .map((e) => Job.fromMap(Map<String, dynamic>.from(e.value), e.key))
        .toList();
  }
}
