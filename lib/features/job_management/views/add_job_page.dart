import 'package:flutter/material.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/models/vehicle_model.dart';
import 'package:fixero/features/job_management/controllers/add_job_controller.dart';

class AddJobPage extends StatefulWidget {
  final AddJobController addJobController;

  const AddJobPage({super.key, required this.addJobController});

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _plateNoController = TextEditingController();
  final TextEditingController _managedByController = TextEditingController();

  final String _selectedStatus = 'Pending';
  Vehicle? _selectedVehicle;
  String _generatedJobId = '';
  bool _isLoading = true;

  // Added dropdown options for service type
  final List<String> _serviceTypeOptions = [
    'Car Repair',
    'Vehicle Safety Check',
    'Fuel Tank Maintenance',
    'Battery Repair',
    'Tire Repair',
  ];
  String? _selectedServiceType; // Changed from TextEditingController to String

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _generatedJobId = widget.addJobController.generateJobId();
    _managedByController.text = 'Workshop Manager'; // Default value
  }

  Future<void> _loadVehicles() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await widget.addJobController.loadVehicles();

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load vehicles: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _plateNoController.dispose();
    _managedByController.dispose();
    super.dispose();
  }

  String _formatDateOnly(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  void _onVehicleSelected(Vehicle vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
      _plateNoController.text = vehicle.plateNo;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedVehicle != null &&
        _selectedServiceType != null) {
      try {
        final newJob = Job(
          jobID: _generatedJobId,
          jobServiceType: _selectedServiceType!, // Use selected service type
          jobDescription: _descriptionController.text,
          jobStatus: _selectedStatus,
          scheduledDate: '', // Removed - empty string
          scheduledTime: '', // Removed - empty string
          estimatedDuration: 0, // Removed - set to 0
          createdAt: _formatDateOnly(DateTime.now()), // Date only
          mechanicID: '', // Removed - empty string
          plateNo: _plateNoController.text,
          managedBy: _managedByController.text,
        );

        // Validate job data
        final validationError = widget.addJobController.validateJobData(newJob);
        if (validationError != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(validationError)));
          return;
        }

        // Add the job
        await widget.addJobController.addNewJob(newJob);
        if (!mounted) return;
        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Job added successfully')));

        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding job: $e')));
      }
    } else if (_selectedVehicle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a vehicle')));
    } else if (_selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service type')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Job')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Job ID Display
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _generatedJobId,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Vehicle Selection
                    const Text(
                      'Select Vehicle',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Vehicle>(
                      value: _selectedVehicle,
                      items: widget.addJobController.vehicles.map((
                        Vehicle vehicle,
                      ) {
                        return DropdownMenuItem<Vehicle>(
                          value: vehicle,
                          child: Text(
                            '${vehicle.plateNo} - ${vehicle.model} ${vehicle.year}',
                          ),
                        );
                      }).toList(),
                      onChanged: (Vehicle? newValue) {
                        if (newValue != null) {
                          _onVehicleSelected(newValue);
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Choose a vehicle',
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a vehicle';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Vehicle Image
                    if (_selectedVehicle != null)
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            child: _selectedVehicle!.vehicleImageUrl.isNotEmpty
                                ? Image.network(
                                    _selectedVehicle!.vehicleImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.car_repair,
                                        size: 80,
                                        color: Colors.grey,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.car_repair,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_selectedVehicle!.model} ${_selectedVehicle!.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Service Type Dropdown (Replaced TextFormField)
                    const Text(
                      'Service Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedServiceType,
                      items: _serviceTypeOptions.map((String serviceType) {
                        return DropdownMenuItem<String>(
                          value: serviceType,
                          child: Text(serviceType),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedServiceType = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select service type',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a service type';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Job description details',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),

                    // Confirm Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Confirm & Create Job',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
