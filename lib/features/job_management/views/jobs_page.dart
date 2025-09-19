import 'package:flutter/material.dart';
import 'package:fixero/common/widgets/bars/fixero_bottom_appbar.dart';
import 'package:fixero/common/widgets/bars/fixero_main_appbar.dart';
import 'package:fixero/data/dao/job_services/job_dao.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/controllers/add_job_controller.dart';
import 'add_job_page.dart';
import 'mechanic_selection_page.dart';

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
    'Ongoing',
    'Scheduled',
    'Completed',
    'Pending',
  ];
  final JobDAO _jobDAO = JobDAO();
  final AddJobController _addJobController =
      AddJobController(); // Add controller instance
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  bool _isLoading = true;
  String? _errorMessage;
  Future? _loadJobsFuture;

  @override
  void initState() {
    super.initState();
    _loadJobsFuture = _loadJobs();
  }

  @override
  void dispose() {
    _loadJobsFuture?.ignore(); // Cancel the future if it's still running
    super.dispose();
  }

  Future<void> _loadJobs() async {
    // Return early if widget is disposed
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobs = await _jobDAO.getAllJobs();

      // Check if widget is still mounted before updating UI
      if (!mounted) return;

      setState(() {
        _allJobs = jobs;
        _filteredJobs = _filterJobs(_allJobs, _selectedFilterIndex);
        _isLoading = false;
      });
    } catch (e) {
      // Check if widget is still mounted before showing error
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load jobs: $e';
        _isLoading = false;
      });
    }
  }

  List<Job> _filterJobs(List<Job> jobs, int filterIndex) {
    switch (filterIndex) {
      case 0: // All
        return jobs;
      case 1: // Ongoing
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'ongoing')
            .toList();
      case 2: // Scheduled
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'scheduled')
            .toList();
      case 3: // Completed
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'completed')
            .toList();
      case 4: // Pending
        return jobs
            .where((job) => job.jobStatus.toLowerCase() == 'pending')
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
    );
  }

  void _navigateToAddJob() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddJobPage(addJobController: _addJobController),
      ),
    ).then((_) {
      // Reload jobs after adding a new one
      _loadJobs();
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
            SizedBox(
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
                          return InkWell(
                            onTap: () => _navigateToJobDetails(job),
                            child: _JobCard(job: job),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
        // Add floating action button for adding new jobs
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Plate - FIRST (larger and prominent)
            Text(
              job.plateNo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 8),

            // Job ID
            Text(
              'Job ID: ${job.jobID}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 4),

            // Service Type (changed from Vehicle)
            Text(
              'Service Type: ${job.jobServiceType}', // Changed to show service type
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 4),

            // Mechanic Name
            Text(
              'Mechanic: ${job.mechanicID}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // Divider
            const Divider(height: 1, color: Colors.grey),

            const SizedBox(height: 12),

            // Status and Dates row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status badge
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

                // Dates
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

class JobDetailsPage extends StatelessWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Details - ${job.jobID}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailSection(
              title: 'Job Information',
              children: [
                _DetailItem(label: 'Job ID', value: job.jobID),
                _DetailItem(label: 'Service Type', value: job.jobServiceType),
                _DetailItem(
                  label: 'Status',
                  value: job.jobStatus,
                  valueColor: _getStatusColor(job.jobStatus),
                ),
                _DetailItem(label: 'Description', value: job.jobDescription),
              ],
            ),

            const SizedBox(height: 20),

            _DetailSection(
              title: 'Vehicle Information',
              children: [_DetailItem(label: 'Vehicle', value: job.plateNo)],
            ),

            const SizedBox(height: 20),

            _DetailSection(
              title: 'Scheduling',
              children: [
                _DetailItem(label: 'Scheduled Date', value: job.scheduledDate),
                _DetailItem(label: 'Scheduled Time', value: job.scheduledTime),
                _DetailItem(
                  label: 'Estimated Duration',
                  value: '${job.estimatedDuration} minutes',
                ),
              ],
            ),

            const SizedBox(height: 20),

            _DetailSection(
              title: 'Timestamps',
              children: [
                _DetailItem(label: 'Created At', value: job.createdAt),
              ],
            ),

            const SizedBox(height: 20),

            _DetailSection(
              title: 'Personnel',
              children: [
                _DetailItem(label: 'Mechanic ID', value: job.mechanicID),
                _DetailItem(label: 'Managed By', value: job.managedBy),
              ],
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Mechanic Selection Page
                  _navigateToMechanicSelection(context);
                },
                child: const Text('Assign Mechanic'),
              ),
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
        return Colors.black;
    }
  }

  void _navigateToMechanicSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MechanicSelectionPage(job: job)),
    ).then((selectedMechanic) {
      if (selectedMechanic != null) {
        // Handle the selected mechanic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assigned ${selectedMechanic.mechanicName} to job'),
            duration: const Duration(seconds: 2),
          ),
        );

        // In a real app, you would update the job with the selected mechanic
        // await _jobDAO.updateJob(job.copyWith(mechanicID: selectedMechanic.mechanicID));
      }
    });
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
