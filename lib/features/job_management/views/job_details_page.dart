import 'package:flutter/material.dart';
import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/views/mechanic_selection_page.dart';

class JobDetailsPage extends StatelessWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Calculate end time
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
            _DetailSection(
              icon: Icons.directions_car,
              title: 'Vehicle Information',
              items: [_DetailItem(label: 'Vehicle', value: job.plateNo)],
            ),
            _DetailSection(
              icon: Icons.schedule,
              title: 'Scheduling',
              items: [
                _DetailItem(label: 'Scheduled Date', value: job.scheduledDate),
                _DetailItem(label: 'Scheduled Time', value: job.scheduledTime),
                if (endTime.isNotEmpty)
                  _DetailItem(label: 'Estimated End Time', value: endTime),
                _DetailItem(
                  label: 'Estimated Duration',
                  value: '${job.estimatedDuration} Hours',
                ),
              ],
            ),
            _DetailSection(
              icon: Icons.access_time,
              title: 'Timestamps',
              items: [_DetailItem(label: 'Created At', value: job.createdAt)],
            ),
            _DetailSection(
              icon: Icons.people,
              title: 'Personnel',
              items: [
                _DetailItem(label: 'Mechanic ID', value: job.mechanicID),
                _DetailItem(label: 'Managed By', value: job.managedBy),
              ],
            ),
            const SizedBox(height: 30),

            // Action Button
            if (job.jobStatus.toLowerCase() == 'pending')
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
            else
              Text(
                'Mechanic can only be assigned to Pending jobs',
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
      MaterialPageRoute(builder: (context) => MechanicSelectionPage(job: job)),
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
}

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
                Icon(icon, color: primary), // only the icon uses primary color
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
