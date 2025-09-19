import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/job_management/models/job.dart';
/*
********************************************************************************
OBJECTIVE: 
- Responsible for fetching and saving data to Firebase under jobservices/jobs/.
- Does not care how we use the data — it only fetches or updates.
********************************************************************************
*/

class JobRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(
    "jobservices/jobs",
  );

  Future<List<Job>> fetchAllJobs() async {
    final snapshot = await _db.get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return Job.fromMap(entry.value, entry.key);
    }).toList();
  }

  Future<void> addJob(Job job) async {
    // Save under your own ID instead of push()
    await _db.child(job.jobID).set({
      ...job.toMap(), // 🔹 expands the whole Job as key-value pairs
      "jobID": job.jobID, // 🔹 explicitly adds/overrides jobID
    });
  }

  Future<void> updateJob(String jobID, Job updatedJob) async {
    await _db.child(jobID).update(updatedJob.toMap());
  }

  Future<void> deleteJob(Job job) async {
    await _db.child(job.jobID).remove();
  }
}
