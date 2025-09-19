// controllers/vehicle_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/vehicle_model.dart';

class VehicleController extends ValueNotifier<int> {
  static final VehicleController _instance = VehicleController._internal();
  factory VehicleController() => _instance;

  VehicleController._internal() : super(0) {
    _init();
  }

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("vehicles");
  final Map<String, Vehicle> _byPlate = {};
  StreamSubscription? _subAdded;
  StreamSubscription? _subChanged;
  StreamSubscription? _subRemoved;

  List<Vehicle> get allVehicles => _byPlate.values.toList(growable: false);

  Future<void> _init() async {
    final snap = await dbRef.get();
    if (snap.exists) {
      for (final child in snap.children) {
        final plate = child.key!;
        final data = Map<String, dynamic>.from(child.value as Map);
        _byPlate[plate] = Vehicle.fromMap(plate, data);
      }
    }
    _notify();

    _subAdded = dbRef.onChildAdded.listen((event) {
      final plate = event.snapshot.key!;
      if (_byPlate.containsKey(plate)) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _byPlate[plate] = Vehicle.fromMap(plate, data);
      _notify();
    });

    _subChanged = dbRef.onChildChanged.listen((event) {
      final plate = event.snapshot.key!;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _byPlate[plate] = Vehicle.fromMap(plate, data);
      _notify();
    });

    _subRemoved = dbRef.onChildRemoved.listen((event) {
      final plate = event.snapshot.key!;
      _byPlate.remove(plate);
      _notify();
    });
  }

  void _notify() => value = _byPlate.length;

  List<Vehicle> fetchVehiclesByOwner(String custID) {
    return _byPlate.values.where((v) => v.ownerID == custID).toList();
  }

  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    super.dispose();
  }
}
