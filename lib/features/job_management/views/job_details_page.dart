import 'package:flutter/material.dart';
import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/views/mechanic_selection_page.dart';
import 'package:provider/provider.dart';
import 'package:fixero/features/job_management/controllers/job_controller.dart';
import 'package:fixero/data/dao/job_services/job_dao.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late Job _currentJob;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentJob = widget.job;
  }

  @override
  Widget build(BuildContext context) {
    final jobController = Provider.of<JobController>(context, listen: false);

    // Calculate end time
    String endTime = '';
    try {
      final scheduledDateParts = _currentJob.scheduledDate.split('-');
      final scheduledTimeParts = _currentJob.scheduledTime.split(':');

      if (scheduledDateParts.length == 3 && scheduledTimeParts.length >= 2) {
        final scheduledDateTime = DateTime(
          int.parse(scheduledDateParts[0]),
          int.parse(scheduledDateParts[1]),
          int.parse(scheduledDateParts[2]),
          int.parse(scheduledTimeParts[0]),
          int.parse(scheduledTimeParts[1]),
        );
        final endDateTime = scheduledDateTime.add(
          Duration(hours: _currentJob.estimatedDuration),
        );
        endTime =
            '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}

    return Scaffold(
      appBar: FixeroSubAppBar(title: 'Job Details', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _DetailSection(
              icon: Icons.work,
              title: 'Job Information',
              items: [
                _DetailItem(label: 'Job ID', value: _currentJob.jobID),
                _DetailItem(
                  label: 'Service Type',
                  value: _currentJob.jobServiceType,
                ),
                _DetailItem(
                  label: 'Status',
                  value: _currentJob.jobStatus,
                  valueColor: _getStatusColor(_currentJob.jobStatus),
                ),
                _DetailItem(
                  label: 'Description',
                  value: _currentJob.jobDescription,
                ),
              ],
            ),
            _DetailSection(
              icon: Icons.directions_car,
              title: 'Vehicle Information',
              items: [
                _DetailItem(label: 'Vehicle', value: _currentJob.plateNo),
              ],
            ),
            _DetailSection(
              icon: Icons.schedule,
              title: 'Scheduling',
              items: [
                _DetailItem(
                  label: 'Scheduled Date',
                  value: _currentJob.scheduledDate,
                ),
                _DetailItem(
                  label: 'Scheduled Time',
                  value: _currentJob.scheduledTime,
                ),
                if (endTime.isNotEmpty)
                  _DetailItem(label: 'Estimated End Time', value: endTime),
                _DetailItem(
                  label: 'Estimated Duration',
                  value: '${_currentJob.estimatedDuration} Hours',
                ),
              ],
            ),
            _DetailSection(
              icon: Icons.access_time,
              title: 'Timestamps',
              items: [
                _DetailItem(label: 'Created At', value: _currentJob.createdAt),
              ],
            ),
            _DetailSection(
              icon: Icons.people,
              title: 'Personnel',
              items: [
                _DetailItem(
                  label: 'Mechanic ID',
                  value: _currentJob.mechanicID,
                ),
                _DetailItem(label: 'Managed By', value: _currentJob.managedBy),
              ],
            ),
            const SizedBox(height: 30),

            // Action Buttons
            if (_currentJob.jobStatus.toLowerCase() == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.assignment_ind, color: Colors.white),
                  label: const Text(
                    'Assign Mechanic',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _navigateToMechanicSelection(context),
                ),
              )
            else if (_currentJob.jobStatus.toLowerCase() == 'scheduled')
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isCancelling
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.cancel, color: Colors.white),
                      label: _isCancelling
                          ? const Text(
                              'Cancelling...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              'Cancel Job',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      onPressed: _isCancelling
                          ? null
                          : () => _showCancelConfirmationDialog(
                              context,
                              jobController,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manager can cancel scheduled jobs',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              Text(
                _currentJob.jobStatus.toLowerCase() == 'cancelled'
                    ? 'This job has been cancelled'
                    : 'Mechanic can only be assigned to Pending jobs',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
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
      MaterialPageRoute(
        builder: (context) => MechanicSelectionPage(job: _currentJob),
      ),
    ).then((selectedMechanic) {
      if (selectedMechanic != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assigned ${selectedMechanic.mechanicName} to job'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    JobController jobController,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text(
            'Are you sure you want to cancel this scheduled job?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelJob(context, jobController);
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelJob(
    BuildContext context,
    JobController jobController,
  ) async {
    setState(() {
      _isCancelling = true;
    });

    try {
      // Create updated job with cancelled status
      final updatedJob = _currentJob.copyWith(jobStatus: 'Cancelled');

      // Update in database through DAO
      final jobDAO = JobDAO();
      await jobDAO.updateJob(updatedJob);

      // Update local state
      setState(() {
        _currentJob = updatedJob;
        _isCancelling = false;
      });

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job has been cancelled successfully'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCancelling = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel job: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// Add the missing widget classes
class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_DetailItem> items;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...items,
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: TextStyle(
                color: valueColor ?? Colors.black,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
