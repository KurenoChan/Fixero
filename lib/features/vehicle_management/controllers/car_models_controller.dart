import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/car_model.dart';
import '../models/vehicle.dart';

class CarModelsController extends ChangeNotifier {
  final List<CarModel> _items = [];
  String _query = '';
  StreamSubscription<DatabaseEvent>? _sub;

  // RTDB vehicles node
  final DatabaseReference _vehiclesRef = FirebaseDatabase.instance.ref(
    'vehicles',
  );

  List<CarModel> get models {
    if (_query.trim().isEmpty) return UnmodifiableListView(_items);
    final q = _query.toLowerCase();
    return UnmodifiableListView(
      _items.where((m) => m.name.toLowerCase().contains(q)).toList(),
    );
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  /// Start listening and aggregating manufacturers counts.
  void listenManufacturers() {
    _sub?.cancel();
    _sub = _vehiclesRef.onValue.listen((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) {
        _items
          ..clear()
          ..addAll(const []);
        notifyListeners();
        return;
      }

      final Map<String, int> counts = {};

      for (final child in snap.children) {
        final value = child.value;
        if (value is Map) {
          final manufacturer = (value['manufacturer'] ?? '').toString().trim();
          if (manufacturer.isEmpty) continue;
          counts.update(manufacturer, (n) => n + 1, ifAbsent: () => 1);
        }
      }

      _items
        ..clear()
        ..addAll(
          counts.entries.map(
            (e) => CarModel(
              name: e.key,
              imagePath: _mapImage(e.key),
              count: e.value,
            ),
          ),
        );

      _items.sort((a, b) => b.count.compareTo(a.count)); // popular first
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ---------- CRUD for /vehicles/{plateNo} ----------

  /// Create a new vehicle at /vehicles/{plateNo}
  Future<void> createVehicle(Vehicle v, {bool keyAsPlate = true}) async {
    final key = keyAsPlate ? v.plateNo : _vehiclesRef.push().key!;
    final ref = _vehiclesRef.child(key);
    final data = v.toMap(keyAsPlate: keyAsPlate);
    await ref.set({...data, if (!keyAsPlate) 'plateNo': v.plateNo});
  }

  /// Update fields for /vehicles/{plateNo}
  Future<void> updateVehicleByPlate(
    String plateNo,
    Map<String, dynamic> changes,
  ) async {
    changes.removeWhere((k, v) => v == null);
    final ref = _vehiclesRef.child(plateNo);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      throw Exception('Vehicle with plate $plateNo does not exist.');
    }
    await ref.update(changes);
  }

  /// Delete /vehicles/{plateNo}
  Future<void> deleteVehicleByPlate(String plateNo) async {
    final ref = _vehiclesRef.child(plateNo);
    await ref.remove();
  }

  // ---------- Helpers ----------
  static String _mapImage(String manufacturerName) {
    final key = manufacturerName.toLowerCase();
    if (key.contains('toyota')) return 'assets/images/manufacturer/toyota.png';
    if (key.contains('perodua')) {
      return 'assets/images/manufacturer/perodua.png';
    }
    if (key.contains('honda')) return 'assets/images/manufacturer/honda.png';
    if (key.contains('proton')) return 'assets/images/manufacturer/proton.png';
    if (key.contains('nissan')) return 'assets/images/manufacturer/nissan.png';
    if (key.contains('ford')) return 'assets/images/manufacturer/ford.png';
    if (key.contains('mazda')) return 'assets/images/manufacturer/mazda.png';
    if (key.contains('hyundai')) {
      return 'assets/images/manufacturer/hyundai.png';
    }
    if (key.contains('volkswagen')) {
      return 'assets/images/manufacturer/volkswagen.png';
    }
    if (key.contains('isuzu')) return 'assets/images/manufacturer/isuzu.png';
    if (key.contains('bmw')) return 'assets/images/manufacturer/bmw.png';
    return 'assets/images/manufacturer/car_generic.png';
  }
}
