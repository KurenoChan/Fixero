import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/vehicle.dart';

class VehicleDetailsController extends ChangeNotifier {
  VehicleDetailsController({required this.plateNo, Vehicle? initialVehicle})
      : _vehicle = initialVehicle;

  final String plateNo;

  Vehicle? _vehicle;
  Vehicle? get vehicle => _vehicle;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _vehKey;
  StreamSubscription<DatabaseEvent>? _vehSub;

  DatabaseReference get _vehiclesRef =>
      FirebaseDatabase.instance.ref('vehicles');

  /// Start listening for this vehicle's data.
  Future<void> listen() async {
    _isLoading = true;
    notifyListeners();

    // Cancel previous
    await _vehSub?.cancel();
    _vehKey = await _resolveKeyByPlate(plateNo);

    if (_vehKey == null) {
      // Not found – stop loading so UI can show a not-found state.
      _vehicle = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Listen to the actual vehicle node
    _vehSub = _vehiclesRef.child(_vehKey!).onValue.listen((event) async {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null || snap.value is! Map) {
        _vehicle = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Parse vehicle
      final m = Map<String, dynamic>.from(snap.value as Map);
      var v = Vehicle.fromMap(m, fallbackKey: _vehKey);

      // Enrich owner (users/customers/{ownerID}) — optional
      String? ownerName;
      String? ownerGender;
      if (v.ownerId.isNotEmpty) {
        final custSnap = await FirebaseDatabase.instance
            .ref('users/customers/${v.ownerId}')
            .get();
        if (custSnap.exists && custSnap.value is Map) {
          final cm = Map<String, dynamic>.from(custSnap.value as Map);
          ownerName = (cm['custName'] ?? cm['name'] ?? '').toString().trim();
          final g = (cm['gender'] ?? '').toString().toLowerCase();
          ownerGender = (g == 'male' || g == 'female') ? g : null;
        }
      }

      _vehicle = v.copyWith(ownerName: ownerName, ownerGender: ownerGender);
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Try /vehicles/{plate} first; if not found, search by body field `plateNo`.
  Future<String?> _resolveKeyByPlate(String plate) async {
    final direct = await _vehiclesRef.child(plate).get();
    if (direct.exists) return plate;

    final q = await _vehiclesRef.orderByChild('plateNo').equalTo(plate).get();
    if (q.exists) {
      for (final c in q.children) {
        return c.key;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _vehSub?.cancel();
    super.dispose();
  }
}
