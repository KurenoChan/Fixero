import 'package:fixero/data/dao/job_services/job_dao.dart';
import 'package:flutter/material.dart';
import 'package:fixero/features/job_management/models/mechanic_model.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/models/auth_service.dart';

class SchedulePage extends StatefulWidget {
  final Job job;
  final Mechanic selectedMechanic;

  const SchedulePage({
    super.key,
    required this.job,
    required this.selectedMechanic,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final JobDAO _jobDAO = JobDAO();
  final AuthService _authService = AuthService();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(hour: 14, minute: 0); // 2:00 PM default
  int _estimatedHours = 1;
  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _confirmSchedule() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get the current logged-in manager ID
      final String? managerId = _authService.getCurrentUserId();

      if (managerId == null) {
        throw Exception('Manager not logged in');
      }
      // Format the scheduled date and time
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Create updated job with new schedule and status
      final updatedJob = widget.job.copyWith(
        mechanicID: widget.selectedMechanic.mechanicID,
        jobStatus: 'Scheduled',
        scheduledDate: scheduledDateTime.toIso8601String().split('T')[0],
        scheduledTime:
            '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        estimatedDuration: _estimatedHours * 60, // Convert hours to minutes
        managedBy: managerId,
      );

      // Update job in Firebase
      await _jobDAO.updateJob(updatedJob);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job scheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to jobs page
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job and Mechanic Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job: ${widget.job.jobID}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Vehicle: ${widget.job.plateNo}'),
                    const SizedBox(height: 8),
                    Text('Service: ${widget.job.jobServiceType}'),
                    const SizedBox(height: 8),
                    Text(
                      'Mechanic: ${widget.selectedMechanic.mechanicName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Specialty: ${widget.selectedMechanic.mechanicSpecialty}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Schedule Section
            const Text(
              'Schedule',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Selected Date Display
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Date Picker Button
            ElevatedButton(
              onPressed: _selectDate,
              child: const Text('Select Date'),
            ),

            const SizedBox(height: 24),

            // Time Selection
            const Text(
              'Start Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '${_selectedTime.format(context)}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _selectTime,
              child: const Text('Select Time'),
            ),

            const SizedBox(height: 24),

            // Estimated Time
            const Text(
              'Estimated Duration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (_estimatedHours > 1) {
                      setState(() {
                        _estimatedHours--;
                      });
                    }
                  },
                ),
                Text(
                  '$_estimatedHours Hour${_estimatedHours > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_estimatedHours < 8) {
                      setState(() {
                        _estimatedHours++;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Confirm Button
            Center(
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _confirmSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Confirm Schedule',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
