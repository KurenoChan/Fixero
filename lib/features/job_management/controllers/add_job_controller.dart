// add_job_controller.dart
import 'package:flutter/foundation.dart';
import 'package:fixero/data/dao/job_services/job_dao.dart';
import 'package:fixero/data/dao/vehicle_services/vehicle_dao.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/features/job_management/models/vehicle_model.dart';

class AddJobController with ChangeNotifier {
  final JobDAO _jobDAO = JobDAO();
  final VehicleDAO _vehicleDAO = VehicleDAO();

  List<Vehicle> _vehicles = [];
  bool _isLoadingVehicles = false;
  String? _errorMessage;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoadingVehicles => _isLoadingVehicles;
  String? get errorMessage => _errorMessage;

  Future<void> loadVehicles() async {
    _isLoadingVehicles = true;
    _errorMessage = null;
    _vehicles = [];
    notifyListeners();

    try {
      print('🟡 [AddJobController] Loading vehicles from DAO...');
      _vehicles = await _vehicleDAO.getAllVehicles();
      print(
        '🟢 [AddJobController] Successfully loaded ${_vehicles.length} vehicles',
      );

      // Debug: Print all loaded vehicles
      for (var vehicle in _vehicles) {
        print('🚗 ${vehicle.plateNo} - ${vehicle.model} ${vehicle.year}');
      }
    } catch (e) {
      _errorMessage = 'Failed to load vehicles: $e';
      print('🔴 [AddJobController] Error loading vehicles: $e');
    } finally {
      _isLoadingVehicles = false;
      notifyListeners();
    }
  }

  Future<void> addNewJob(Job job) async {
    try {
      await _jobDAO.addJob(job);
    } catch (e) {
      throw Exception('Failed to add job: $e');
    }
  }

  String generateJobId() {
    final now = DateTime.now();
    final hours = now.hour.toString().padLeft(2, '0');
    final minutes = now.minute.toString().padLeft(2, '0');
    final seconds = now.second.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();
    final random = (now.millisecondsSinceEpoch % 10000).toString().padLeft(
      4,
      '0',
    );

    return 'JOB-$hours$minutes$seconds-$day$month$year-$random';
  }

  String? validateJobData(Job job) {
    if (job.jobServiceType.isEmpty) return 'Service type is required';
    if (job.plateNo.isEmpty) return 'Vehicle plate number is required';
    // Removed scheduled date, time, and duration validation
    return null;
  }
}
