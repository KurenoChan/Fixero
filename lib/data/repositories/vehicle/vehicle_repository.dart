import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/job_management/models/vehicle_model.dart';

class VehicleRepository {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Future<List<Vehicle>> fetchAllVehicles() async {
    try {
      print('🟡 [VehicleRepository] Fetching vehicles from Firebase...');
      print('🟡 Database path: vehicles');

      final snapshot = await _databaseRef.child('vehicles').get();
      print('🟡 Snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        final Map<dynamic, dynamic> vehiclesData =
            snapshot.value as Map<dynamic, dynamic>;
        print('🟢 Found ${vehiclesData.length} vehicles in Firebase');

        final List<Vehicle> vehicles = [];

        vehiclesData.forEach((plateNo, vehicleData) {
          print('📦 Processing vehicle: $plateNo');
          print('📦 Raw vehicle data: $vehicleData');

          try {
            final vehicle = Vehicle.fromMap(
              Map<String, dynamic>.from(vehicleData as Map<dynamic, dynamic>),
              plateNo as String,
            );
            vehicles.add(vehicle);
            print(
              '✅ Successfully parsed: ${vehicle.plateNo} - ${vehicle.model}',
            );
          } catch (e) {
            print('🔴 Error parsing vehicle $plateNo: $e');
            print('🔴 Vehicle data: $vehicleData');
          }
        });

        print('🟢 Total vehicles parsed: ${vehicles.length}');
        return vehicles;
      } else {
        print('🟡 No vehicles found in Firebase database');
        return [];
      }
    } catch (e) {
      print('🔴 [VehicleRepository] Error fetching vehicles: $e');
      print('🔴 Error type: ${e.runtimeType}');
      throw Exception('Failed to fetch vehicles: $e');
    }
  }

  Future<Vehicle?> fetchVehicleByPlateNo(String plateNo) async {
    try {
      print('🟡 Fetching vehicle by plate: $plateNo');
      final snapshot = await _databaseRef.child('vehicles/$plateNo').get();

      if (snapshot.exists) {
        final vehicleData = Map<String, dynamic>.from(
          snapshot.value as Map<dynamic, dynamic>,
        );
        print('🟢 Found vehicle: $vehicleData');
        return Vehicle.fromMap(vehicleData, plateNo);
      } else {
        print('🟡 No vehicle found with plate: $plateNo');
        return null;
      }
    } catch (e) {
      print('🔴 Error fetching vehicle $plateNo: $e');
      throw Exception('Failed to fetch vehicle: $e');
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _databaseRef
          .child('vehicles/${vehicle.plateNo}')
          .set(vehicle.toMap());
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      await _databaseRef
          .child('vehicles/${vehicle.plateNo}')
          .update(vehicle.toMap());
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  Future<void> deleteVehicle(String plateNo) async {
    try {
      await _databaseRef.child('vehicles/$plateNo').remove();
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  Future<List<Vehicle>> fetchVehiclesByOwner(String ownerID) async {
    try {
      final snapshot = await _databaseRef.child('vehicles').get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> vehiclesData =
            snapshot.value as Map<dynamic, dynamic>;
        final List<Vehicle> vehicles = [];

        vehiclesData.forEach((plateNo, vehicleData) {
          final vehicle = Vehicle.fromMap(
            Map<String, dynamic>.from(vehicleData as Map<dynamic, dynamic>),
            plateNo as String,
          );
          if (vehicle.ownerID == ownerID) {
            vehicles.add(vehicle);
          }
        });

        return vehicles;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch vehicles by owner: $e');
    }
  }
}
