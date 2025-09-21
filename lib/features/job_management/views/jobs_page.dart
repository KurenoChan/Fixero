import 'package:flutter/material.dart';
import 'package:fixero/common/widgets/bars/fixero_bottom_appbar.dart';
import 'package:fixero/common/widgets/bars/fixero_main_appbar.dart';
import 'package:fixero/data/dao/job_services/job_dao.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/controllers/add_job_controller.dart';
import 'package:fixero/features/job_management/views/job_details_page.dart';
import 'add_job_page.dart';
import 'dart:async';

class JobsPage extends StatefulWidget {
  static const routeName = '/jobs';
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filterOptions = [
    'All',
    'Pending',
    'Scheduled',
    'Ongoing',
    'Completed',
    'Cancelled',
  ];
  final JobDAO _jobDAO = JobDAO();
  final AddJobController _addJobController = AddJobController();
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  bool _isLoading = true;
  String? _errorMessage;
  Future? _loadJobsFuture;
  Timer? _statusUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadJobsFuture = _loadJobs();

    // periodic status update
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAndUpdateJobStatuses();
    });
  }

  @override
  void dispose() {
    _loadJobsFuture?.ignore();
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobs = await _jobDAO.getAllJobs();

      // Update statuses based on current time
      final updatedJobs = await _updateJobStatusesBasedOnTime(jobs);

      if (!mounted) return;

      setState(() {
        _allJobs = updatedJobs;
        _filteredJobs = _filterJobs(_allJobs, _selectedFilterIndex);
        _isLoading = false;
      });

      // ✅ Immediately re-check statuses after loading
      _checkAndUpdateJobStatuses();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load jobs: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<Job>> _updateJobStatusesBasedOnTime(List<Job> jobs) async {
    final now = DateTime.now();
    final updatedJobs = <Job>[];
    bool needsUpdate = false;

    for (final job in jobs) {
      Job updatedJob = job;

      if (job.jobStatus.toLowerCase() == 'completed' ||
          job.jobStatus.toLowerCase() == 'cancelled') {
        updatedJobs.add(updatedJob);
        continue;
      }

      try {
        final scheduledDateParts = job.scheduledDate.split('-');
        final scheduledTimeParts = job.scheduledTime.split(':');

        if (scheduledDateParts.length == 3 && scheduledTimeParts.length >= 2) {
          final scheduledDateTime = DateTime(
            int.parse(scheduledDateParts[0]),
            int.parse(scheduledDateParts[1]),
            int.parse(scheduledDateParts[2]),
            int.parse(scheduledTimeParts[0]),
            int.parse(scheduledTimeParts[1]),
          );

          final endDateTime = scheduledDateTime.add(
            Duration(hours: job.estimatedDuration),
          );

          if (now.isAfter(endDateTime)) {
            if (job.jobStatus.toLowerCase() != 'completed') {
              updatedJob = job.copyWith(jobStatus: 'Completed');
              needsUpdate = true;
              debugPrint('Job ${job.jobID} marked as completed');
            }
          } else if (now.isAfter(scheduledDateTime) &&
              now.isBefore(endDateTime)) {
            if (job.jobStatus.toLowerCase() != 'ongoing') {
              updatedJob = job.copyWith(jobStatus: 'Ongoing');
              needsUpdate = true;
              debugPrint('Job ${job.jobID} marked as ongoing');
            }
          } else if (now.isBefore(scheduledDateTime) &&
              job.jobStatus.toLowerCase() != 'scheduled' &&
              job.jobStatus.toLowerCase() != 'pending') {
            updatedJob = job.copyWith(jobStatus: 'Scheduled');
            needsUpdate = true;
            debugPrint('Job ${job.jobID} marked as scheduled');
          }
        }
      } catch (e) {
        debugPrint('Error parsing date for job ${job.jobID}: $e');
      }

      updatedJobs.add(updatedJob);
    }

    if (needsUpdate) {
      for (final job in updatedJobs) {
        final originalJob = jobs.firstWhere(
          (j) => j.jobID == job.jobID,
          orElse: () => job,
        );

        if (job.jobStatus != originalJob.jobStatus) {
          await _jobDAO.updateJob(job);
          debugPrint('Updated job ${job.jobID} status to ${job.jobStatus}');
        }
      }
    }

    return updatedJobs;
  }

  void _checkAndUpdateJobStatuses() async {
    if (!mounted) return;

    try {
      final updatedJobs = await _updateJobStatusesBasedOnTime(_allJobs);

      if (!mounted) return;

      final hasChanges =
          updatedJobs.length == _allJobs.length &&
          updatedJobs.asMap().entries.any((entry) {
            final index = entry.key;
            return entry.value.jobStatus != _allJobs[index].jobStatus;
          });

      if (hasChanges) {
        setState(() {
          _allJobs = updatedJobs;
          _filteredJobs = _filterJobs(_allJobs, _selectedFilterIndex);
        });
      }
    } catch (e) {
      debugPrint('Error updating job statuses: $e');
    }
  }

  List<Job> _filterJobs(List<Job> jobs, int filterIndex) {
    switch (filterIndex) {
      case 0: // All
        return jobs;
      case 1: // Pending
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'pending')
            .toList();
      case 2: // Scheduled
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'scheduled')
            .toList();
      case 3: // Ongoing
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'ongoing')
            .toList();
      case 4: // Completed
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'completed')
            .toList();
      case 5: // Cancelled
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'cancelled')
            .toList();
      default:
        return jobs;
    }
  }

  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilterIndex = index;
      _filteredJobs = _filterJobs(_allJobs, index);
    });
  }

  void _navigateToJobDetails(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailsPage(job: job)),
    ).then((_) {
      _loadJobs(); // ✅ reload when returning
    });
  }

  void _navigateToAddJob() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddJobPage(addJobController: _addJobController),
      ),
    ).then((_) {
      _loadJobs(); // ✅ reload when returning
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: FixeroMainAppBar(title: "Jobs"),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search jobs',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      _filteredJobs = _filterJobs(
                        _allJobs,
                        _selectedFilterIndex,
                      );
                    } else {
                      _filteredJobs =
                          _filterJobs(_allJobs, _selectedFilterIndex)
                              .where(
                                (job) =>
                                    job.jobID.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ) ||
                                    job.plateNo.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ),
                              )
                              .toList();
                    }
                  });
                },
              ),
            ),

            // Filter chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(_filterOptions[index]),
                      selected: _selectedFilterIndex == index,
                      onSelected: (selected) {
                        if (selected) {
                          _onFilterChanged(index);
                        }
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedFilterIndex == index
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Jobs list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _filteredJobs.isEmpty
                  ? const Center(child: Text('No jobs found'))
                  : RefreshIndicator(
                      onRefresh: _loadJobs,
                      child: ListView.builder(
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: InkWell(
                              onTap: () => _navigateToJobDetails(job),
                              child: _JobCard(job: job),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddJob,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: const FixeroBottomAppBar(),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    String endTime = '';
    try {
      final scheduledDateParts = job.scheduledDate.split('-');
      final scheduledTimeParts = job.scheduledTime.split(':');

      if (scheduledDateParts.length == 3 && scheduledTimeParts.length >= 2) {
        final scheduledDateTime = DateTime(
          int.parse(scheduledDateParts[0]),
          int.parse(scheduledDateParts[1]),
          int.parse(scheduledDateParts[2]),
          int.parse(scheduledTimeParts[0]),
          int.parse(scheduledTimeParts[1]),
        );

        final endDateTime = scheduledDateTime.add(
          Duration(hours: job.estimatedDuration),
        );
        endTime =
            '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      debugPrint('Error calculating end time: $e');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.plateNo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Job ID: ${job.jobID}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Service Type: ${job.jobServiceType}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            if (job.jobStatus.toLowerCase() == 'ongoing' && endTime.isNotEmpty)
              Text(
                'Estimated Finish: $endTime',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Mechanic: ${job.mechanicID}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(job.jobStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.jobStatus,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Scheduled: ${job.scheduledDate}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Created: ${_formatDate(job.createdAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
