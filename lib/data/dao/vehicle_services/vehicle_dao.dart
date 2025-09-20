// vehicle_dao.dart
import 'package:fixero/data/repositories/vehicle/vehicle_repository.dart';
import 'package:fixero/features/job_management/models/vehicle_model.dart';

class VehicleDAO {
  final VehicleRepository _repo = VehicleRepository();

  Future<List<Vehicle>> getAllVehicles() async {
    return await _repo.fetchAllVehicles();
  }

  Future<Vehicle?> getVehicleByPlateNo(String plateNo) async {
    return await _repo.fetchVehicleByPlateNo(plateNo);
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _repo.addVehicle(vehicle);
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _repo.updateVehicle(vehicle);
  }

  Future<void> deleteVehicle(String plateNo) async {
    await _repo.deleteVehicle(plateNo);
  }

  Future<List<Vehicle>> getVehiclesByOwner(String ownerID) async {
    return await _repo.fetchVehiclesByOwner(ownerID);
  }

  // Additional utility methods
  Future<List<Vehicle>> searchVehicles(String query) async {
    final allVehicles = await getAllVehicles();
    return allVehicles
        .where(
          (vehicle) =>
              vehicle.plateNo.toLowerCase().contains(query.toLowerCase()) ||
              vehicle.model.toLowerCase().contains(query.toLowerCase()) ||
              vehicle.make.toLowerCase().contains(query.toLowerCase()) ||
              vehicle.ownerID.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<bool> vehicleExists(String plateNo) async {
    final vehicle = await getVehicleByPlateNo(plateNo);
    return vehicle != null;
  }
}
