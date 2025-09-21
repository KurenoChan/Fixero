import 'package:fixero/data/dao/job_services/job_dao.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/views/job_demand_chart_data.dart';
import 'package:fixero/features/job_management/views/job_demand_chart_helper.dart';
import 'package:flutter/material.dart';

class JobController extends ChangeNotifier {
  final JobDAO _dao = JobDAO();

  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadJobs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _jobs = await _dao.getAllJobs();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  List<Job> get ongoingJobs =>
      _jobs.where((e) => e.jobStatus == "Ongoing").toList();

  List<Job> get completedJobs =>
      _jobs.where((e) => e.jobStatus == "Completed").toList();

  List<Job> get cancelledJobs =>
      _jobs.where((e) => e.jobStatus == "Cancelled").toList();

  List<Job> get pendingJobs =>
      _jobs.where((e) => e.jobStatus == "Pending").toList();

  List<String> getJobServiceTypes() {
    return _jobs
        .map((e) => e.jobServiceType.trim().toLowerCase())
        .toSet()
        .toList();
  }

  Job? getJobByJobID(String id) {
    try {
      return _jobs.firstWhere((job) => job.jobID == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateJob(Job job) async {
    try {
      await _dao.updateJob(job);
      // Refresh the jobs list to reflect the update
      await loadJobs();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<JobDemandChartData> get demandByMonth =>
      aggregateJobDemandByMonth(_jobs);
}
