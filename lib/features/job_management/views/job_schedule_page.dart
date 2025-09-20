import 'package:fixero/data/dao/job_services/job_dao.dart';
import 'package:flutter/material.dart';
import 'package:fixero/features/job_management/models/mechanic_model.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/models/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';

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
  TimeOfDay _selectedTime = const TimeOfDay(
    hour: 14,
    minute: 0,
  ); // Default 2 PM
  int _estimatedHours = 1;
  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _confirmSchedule() async {
    setState(() => _isSubmitting = true);

    try {
      final String? managerId = _authService.getCurrentUserId();
      if (managerId == null) throw Exception('Manager not logged in');

      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final updatedJob = widget.job.copyWith(
        mechanicID: widget.selectedMechanic.mechanicID,
        jobStatus: 'Scheduled',
        scheduledDate: scheduledDateTime.toIso8601String().split('T')[0],
        scheduledTime:
            '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        estimatedDuration: _estimatedHours,
        managedBy: managerId,
      );

      await _jobDAO.updateJob(updatedJob);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job scheduled successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule job: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: FixeroSubAppBar(title: 'Schedule Job', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job + Mechanic Details
            _buildSectionCard(
              title: "Job & Mechanic Info",
              icon: Icons.build_circle_outlined,
              color: theme.colorScheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    "Job ID",
                    widget.job.jobID,
                    Icons.confirmation_number,
                    theme.colorScheme.primary,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    "Vehicle",
                    widget.job.plateNo,
                    Icons.directions_car,
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    "Service",
                    widget.job.jobServiceType,
                    Icons.build,
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    "Mechanic",
                    "${widget.selectedMechanic.mechanicName} (${widget.selectedMechanic.mechanicSpecialty})",
                    Icons.person_outline,
                    theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Schedule Details Section
            _buildSectionTitle("Schedule Details", theme.colorScheme.primary),

            const SizedBox(height: 16),

            // Date Picker
            _buildSectionCard(
              title: "Date",
              icon: Icons.calendar_today_outlined,
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Change"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Time Picker
            _buildSectionCard(
              title: "Start Time",
              icon: Icons.access_time,
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectTime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Change"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Duration Selector
            _buildSectionCard(
              title: "Estimated Duration",
              icon: Icons.timer_outlined,
              color: theme.colorScheme.primary,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: _estimatedHours > 1
                          ? theme.colorScheme.primary
                          : Colors.grey,
                      iconSize: 32,
                      onPressed: () {
                        if (_estimatedHours > 1) {
                          setState(() => _estimatedHours--);
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_estimatedHours Hour${_estimatedHours > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: _estimatedHours < 8
                          ? theme.colorScheme.primary
                          : Colors.grey,
                      iconSize: 32,
                      onPressed: () {
                        if (_estimatedHours < 8) {
                          setState(() => _estimatedHours++);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Confirm Button
            _isSubmitting
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 22),
                      label: const Text(
                        "Confirm Schedule",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Section Title with Icon
  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Icon(Icons.event_note, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 🔹 Reusable Card Section
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable Info Row
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
