import 'package:fixero/data/repositories/job_services/job_repository.dart';
import 'package:fixero/features/job_management/models/job.dart';
/*
********************************************************************************
OBJECTIVE: 
- Uses the repository to get raw jobs.
- Does not care how we use the data — it only fetches or updates.
********************************************************************************
*/

class JobDAO {
  final JobRepository _repo = JobRepository();

  Future<List<Job>> getAllJobs() async {
    return await _repo.fetchAllJobs();
  }

  Future<void> addJob(Job job) async {
    await _repo.addJob(job);
  }

  Future<void> updateJob(Job job) async {
    await _repo.updateJob(job.jobID, job); // pass jobID explicitly
  }

  Future<void> deleteJob(Job job) async {
    await _repo.deleteJob(job);
  }
}
