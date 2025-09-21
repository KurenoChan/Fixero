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

  final List<String> _serviceTypeOptions = [
    'Car Repair',
    'Vehicle Safety Check',
    'Fuel Tank Maintenance',
    'Battery Repair',
    'Tire Repair',
  ];
  String? _selectedServiceType;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _generatedJobId = widget.addJobController.generateJobId();
    _managedByController.text = 'Workshop Manager';
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

  String _formatDateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
          jobServiceType: _selectedServiceType!,
          jobDescription: _descriptionController.text,
          jobStatus: _selectedStatus,
          scheduledDate: '',
          scheduledTime: '',
          estimatedDuration: 0,
          createdAt: _formatDateOnly(DateTime.now()),
          mechanicID: '',
          plateNo: _plateNoController.text,
          managedBy: _managedByController.text,
        );

        final validationError = widget.addJobController.validateJobData(newJob);
        if (validationError != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(validationError)));
          return;
        }

        await widget.addJobController.addNewJob(newJob);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Job added successfully')));
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
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Job'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Job ID Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.work, color: primary),
                        title: const Text(
                          'Job ID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _generatedJobId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Vehicle Dropdown
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
                          child: Row(
                            children: [
                              Icon(Icons.directions_car, color: primary),
                              const SizedBox(width: 8),
                              Text(
                                '${vehicle.plateNo} - ${vehicle.model} ${vehicle.year}',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (Vehicle? newValue) {
                        if (newValue != null) _onVehicleSelected(newValue);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Choose a vehicle',
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a vehicle' : null,
                    ),

                    const SizedBox(height: 20),

                    // Vehicle Preview Card
                    if (_selectedVehicle != null)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child:
                                  _selectedVehicle!.vehicleImageUrl.isNotEmpty
                                  ? Image.network(
                                      _selectedVehicle!.vehicleImageUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 180,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.car_repair,
                                                size: 80,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      height: 180,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.car_repair,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                '${_selectedVehicle!.model} ${_selectedVehicle!.year}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Service Type Dropdown
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
                          child: Row(
                            children: [
                              Icon(Icons.build_circle, color: primary),
                              const SizedBox(width: 8),
                              Text(serviceType),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() => _selectedServiceType = newValue);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select service type',
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a service type' : null,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Job description details',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description, color: primary),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),

                    // Confirm Button
                    ElevatedButton.icon(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
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
