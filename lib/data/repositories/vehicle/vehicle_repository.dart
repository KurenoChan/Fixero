import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/job_management/models/vehicle_model.dart';
import 'package:flutter/material.dart';

class VehicleRepository {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Future<List<Vehicle>> fetchAllVehicles() async {
    try {
      debugPrint('🟡 [VehicleRepository] Fetching vehicles from Firebase...');
      debugPrint('🟡 Database path: vehicles');

      final snapshot = await _databaseRef.child('vehicles').get();
      debugPrint('🟡 Snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        final Map<dynamic, dynamic> vehiclesData =
            snapshot.value as Map<dynamic, dynamic>;
        debugPrint('🟢 Found ${vehiclesData.length} vehicles in Firebase');

        final List<Vehicle> vehicles = [];

        vehiclesData.forEach((plateNo, vehicleData) {
          debugPrint('📦 Processing vehicle: $plateNo');
          debugPrint('📦 Raw vehicle data: $vehicleData');

          try {
            final vehicle = Vehicle.fromMap(
              Map<String, dynamic>.from(vehicleData as Map<dynamic, dynamic>),
              plateNo as String,
            );
            vehicles.add(vehicle);
            debugPrint(
              '✅ Successfully parsed: ${vehicle.plateNo} - ${vehicle.model}',
            );
          } catch (e) {
            debugPrint('🔴 Error parsing vehicle $plateNo: $e');
            debugPrint('🔴 Vehicle data: $vehicleData');
          }
        });

        debugPrint('🟢 Total vehicles parsed: ${vehicles.length}');
        return vehicles;
      } else {
        debugPrint('🟡 No vehicles found in Firebase database');
        return [];
      }
    } catch (e) {
      debugPrint('🔴 [VehicleRepository] Error fetching vehicles: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');
      throw Exception('Failed to fetch vehicles: $e');
    }
  }

  Future<Vehicle?> fetchVehicleByPlateNo(String plateNo) async {
    try {
      debugPrint('🟡 Fetching vehicle by plate: $plateNo');
      final snapshot = await _databaseRef.child('vehicles/$plateNo').get();

      if (snapshot.exists) {
        final vehicleData = Map<String, dynamic>.from(
          snapshot.value as Map<dynamic, dynamic>,
        );
        debugPrint('🟢 Found vehicle: $vehicleData');
        return Vehicle.fromMap(vehicleData, plateNo);
      } else {
        debugPrint('🟡 No vehicle found with plate: $plateNo');
        return null;
      }
    } catch (e) {
      debugPrint('🔴 Error fetching vehicle $plateNo: $e');
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
