import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart'; // Make sure this file exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  final DatabaseReference _mechanicsRef = FirebaseDatabase.instance.ref().child('users/mechanics');
  List<Mechanic> _mechanics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
  }

  Future<void> _fetchMechanics() async {
  try {
    DatabaseEvent event = await _mechanicsRef.once();
    DataSnapshot snapshot = event.snapshot;
    
    if (snapshot.value != null) {
      Map<dynamic, dynamic> mechanicsData = snapshot.value as Map<dynamic, dynamic>;
      List<Mechanic> loadedMechanics = [];
      
      mechanicsData.forEach((key, value) {
        // Check if the value is a Map (individual mechanic data)
        if (value is Map<dynamic, dynamic>) {
          loadedMechanics.add(Mechanic(
            id: key.toString(),
            name: value['mechanicName'] ?? 'Unknown',
            email: value['mechanicEmail'] ?? '',
            phone: value['mechanicTel'] ?? '',
            specialty: value['mechanicSpecialty'] ?? 'General Technician',
            status: value['mechanicStatus'] ?? 'Available',
            joinedDate: value['joinedDate'] ?? '',
          ));
        }
      });
      
      setState(() {
        _mechanics = loadedMechanics;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  } catch (error) {
    print('Error fetching mechanics: $error');
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load mechanics data: $error')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Mechanics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMechanics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mechanics.isEmpty
              ? const Center(child: Text('No mechanics available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _mechanics.length,
                  itemBuilder: (context, index) {
                    final mechanic = _mechanics[index];
                    final isAvailable = mechanic.status == 'Available';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(mechanic.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mechanic.phone),
                            Text(mechanic.specialty),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  isAvailable ? Icons.check_circle : Icons.cancel,
                                  color: isAvailable ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mechanic.status,
                                  style: TextStyle(
                                    color: isAvailable ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            _showMechanicDetails(mechanic);
                          },
                        ),
                        onTap: isAvailable
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScheduleScreen(mechanic: mechanic),
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

  void _showMechanicDetails(Mechanic mechanic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(mechanic.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${mechanic.email}'),
              Text('Phone: ${mechanic.phone}'),
              Text('Specialty: ${mechanic.specialty}'),
              if (mechanic.joinedDate.isNotEmpty)
                Text('Joined: ${mechanic.joinedDate}'),
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
  final Mechanic? mechanic;

  const ScheduleScreen({super.key, this.mechanic});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  final DatabaseReference _schedulesRef = FirebaseDatabase.instance.ref().child('schedules');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mechanic != null
            ? 'Schedule for ${widget.mechanic!.name}'
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
            if (widget.mechanic != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mechanic!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.mechanic!.phone),
                      Text(widget.mechanic!.specialty),
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
                  _saveScheduleToFirebase();
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
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void _saveScheduleToFirebase() {
    if (widget.mechanic == null) return;
    
    String scheduleId = _schedulesRef.push().key!;
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    _schedulesRef.child(scheduleId).set({
      'mechanicId': widget.mechanic!.id,
      'mechanicName': widget.mechanic!.name,
      'date': formattedDate,
      'startTime': '${_startTime.hour}:${_startTime.minute}',
      'endTime': '${_endTime.hour}:${_endTime.minute}',
      'createdAt': DateTime.now().toString(),
    }).then((_) {
      _showBookingConfirmation();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save schedule: $error')),
      );
    });
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
              if (widget.mechanic != null)
                Text('Mechanic: ${widget.mechanic!.name}'),
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

class Mechanic {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String status;
  final String joinedDate;

  Mechanic({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.status,
    required this.joinedDate,
  });
}