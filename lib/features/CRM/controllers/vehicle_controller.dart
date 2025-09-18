// vehicle_controller.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/vehicle_model.dart';

class VehicleController {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("vehicles");

  Future<List<Vehicle>> fetchVehiclesByOwner(String ownerId) async {
    final snap = await _dbRef.get();
    if (!snap.exists) return [];

    final allVehicles = Map<String, dynamic>.from(snap.value as Map);
    final filtered = allVehicles.entries.where((e) {
      final data = Map<String, dynamic>.from(e.value);
      return data['ownerID'] == ownerId;
    });

    return filtered
        .map((e) => Vehicle.fromMap(Map<String, dynamic>.from(e.value), e.key))
        .toList();
  }
}
