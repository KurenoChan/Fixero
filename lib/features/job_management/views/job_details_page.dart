import 'package:flutter/material.dart';
import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/views/mechanic_selection_page.dart';

class JobDetailsPage extends StatelessWidget {
  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Calculate end time for the job
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

    return Scaffold(
      appBar: FixeroSubAppBar(title: 'Job Details', showBackButton: true),
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
                if (endTime.isNotEmpty)
                  _DetailItem(
                    label: 'Estimated End Time',
                    value: endTime,
                    valueColor: Colors.blue,
                  ),
                _DetailItem(
                  label: 'Estimated Duration',
                  value: '${job.estimatedDuration} Hours',
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

            // Only show Assign Mechanic button for Pending status
            if (job.jobStatus.toLowerCase() == 'pending')
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToMechanicSelection(context);
                  },
                  child: const Text('Assign Mechanic'),
                ),
              )
            else
              Center(
                child: Text(
                  'Mechanic can only be assigned to Pending jobs',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
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
