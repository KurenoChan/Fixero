import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const JobManagementApp());
}

class JobManagementApp extends StatelessWidget {
  const JobManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Job Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WorkersScreen(),
      routes: {
        '/workers': (context) => const WorkersScreen(),
        '/schedule': (context) => const ScheduleScreen(),
      },
    );
  }
}

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  final List<Worker> _workers = [
    Worker(
      id: '1',
      name: 'Tech Been Hang',
      email: 'techbeen@example.com',
      phone: 'VEK 3400/5121',
      skills: 'Language Management',
      experience: 5,
      available: true,
    ),
    Worker(
      id: '2',
      name: 'Koh Zhang Hang',
      email: 'kohzhang@example.com',
      phone: 'VEK 3400/5121',
      skills: 'Language Systems',
      experience: 4,
      available: true,
    ),
    Worker(
      id: '3',
      name: 'Hang Jin Hao',
      email: 'hangjin@example.com',
      phone: 'VEK 3400/5121',
      skills: 'General Technician',
      experience: 3,
      available: true,
    ),
    Worker(
      id: '4',
      name: 'Mainamined Fork',
      email: 'mainamined@example.com',
      phone: '123-456-7890',
      skills: 'Team Lead',
      experience: 7,
      available: false,
    ),
    Worker(
      id: '5',
      name: 'Low Ah Koo',
      email: 'lowahkoo@example.com',
      phone: '987-654-3210',
      skills: 'Anesthetics Specialist',
      experience: 6,
      available: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Workers'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _workers.length,
        itemBuilder: (context, index) {
          final worker = _workers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(worker.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.phone),
                  Text(worker.skills),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        worker.available ? Icons.check_circle : Icons.cancel,
                        color: worker.available ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        worker.available ? 'Available' : 'Not Available',
                        style: TextStyle(
                          color: worker.available ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  _showWorkerDetails(worker);
                },
              ),
              onTap: worker.available
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleScreen(worker: worker),
                  ),
                );
              }
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _showWorkerDetails(Worker worker) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(worker.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${worker.email}'),
              Text('Phone: ${worker.phone}'),
              Text('Experience: ${worker.experience} years'),
              const SizedBox(height: 8),
              const Text(
                'Technical Skills:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(worker.skills),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  final Worker? worker;

  const ScheduleScreen({super.key, this.worker});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.worker != null
            ? 'Schedule for ${widget.worker!.name}'
            : 'Work Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.worker != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.worker!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.worker!.phone),
                      Text(widget.worker!.skills),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Calendar Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                          _selectedDate.year, _selectedDate.month - 1, 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(
                          _selectedDate.year, _selectedDate.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calendar
            _buildCalendar(),
            const SizedBox(height: 24),

            // Time Selection
            const Text(
              'Start Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectStartTime(context),
              child: Row(
                children: [
                  Text(_formatTimeOfDay(_startTime)),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'End Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectEndTime(context),
              child: Row(
                children: [
                  Text(_formatTimeOfDay(_endTime)),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showBookingConfirmation();
                },
                child: const Text('Confirm Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    // Get first day of the month
    DateTime firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    // Get number of days in the month
    int daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0)
        .day;
    // Get weekday of first day (1 = Monday, 7 = Sunday)
    int firstWeekday = firstDay.weekday;

    // Generate list of day numbers with empty placeholders for days before the first
    List<int?> days = [];
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }

    return Column(
      children: [
        // Weekday headers
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Mon', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Tue', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Wed', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Thu', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Fri', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Sat', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Sun', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            if (days[index] == null) {
              return const SizedBox.shrink();
            }

            final day = days[index]!;
            final isSelected = day == _selectedDate.day;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                });
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        // Ensure end time is after start time
        if (_endTime.hour < picked.hour ||
            (_endTime.hour == picked.hour && _endTime.minute <= picked.minute)) {
          _endTime = TimeOfDay(hour: picked.hour + 1, minute: picked.minute);
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null && picked != _endTime) {
      // Ensure end time is after start time
      if (picked.hour > _startTime.hour ||
          (picked.hour == _startTime.hour && picked.minute > _startTime.minute)) {
        setState(() {
          _endTime = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); // Use 'jm' for 12-hour format with AM/PM
    return format.format(dt);
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Booking Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.worker != null)
                Text('Worker: ${widget.worker!.name}'),
              Text('Date: ${DateFormat('MMMM d, yyyy').format(_selectedDate)}'),
              Text('Time: ${_formatTimeOfDay(_startTime)} - ${_formatTimeOfDay(_endTime)}'),
              const SizedBox(height: 16),
              const Text('Your booking has been successfully created!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}

class Worker {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String skills;
  final int experience;
  final bool available;

  Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.skills,
    required this.experience,
    required this.available,
  });
}