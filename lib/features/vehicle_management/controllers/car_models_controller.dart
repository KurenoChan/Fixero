import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/car_model.dart';

/// Aggregates vehicles by `manufacturer` from Firebase Realtime Database.
/// Usage:
///   controller.listenManufacturers();  // start realtime listener
///   controller.dispose();              // will cancel listener
class CarModelsController extends ChangeNotifier {
  final List<CarModel> _items = [];
  String _query = '';
  StreamSubscription<DatabaseEvent>? _sub;

  List<CarModel> get models {
    final list = List<CarModel>.from(_items);
    if (_query.trim().isEmpty) return UnmodifiableListView(list);
    final q = _query.toLowerCase();
    return UnmodifiableListView(
      list.where((m) => m.name.toLowerCase().contains(q)),
    );
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  /// Start listening to vehicles under `vehicles` node.
  /// Expected RTDB shape: an array/list of vehicle maps or child nodes,
  /// each with a `manufacturer` key (e.g., "Toyota", "Honda", ...).
  Future<void> listenManufacturers({String path = 'vehicles'}) async {
    // Cancel any previous listener
    await _sub?.cancel();
    final ref = FirebaseDatabase.instance.ref(path);

    _sub = ref.onValue.listen((event) {
      final snap = event.snapshot;
      if (!snap.exists) {
        _items.clear();
        notifyListeners();
        return;
      }

      final Map<String, int> counts = {};

      // Compatible with both list-like and map-like RTDB structures.
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

      // Optional: sort alphabetically or by count desc
      _items.sort((a, b) => b.count.compareTo(a.count));
      notifyListeners();
    });
  }

  /// Stop listening
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // Maps a manufacturer name to a logo asset
  String _mapImage(String manufacturer) {
    final key = manufacturer.toLowerCase();
    if (key.contains('toyota')) return 'assets/images/manufacturer/toyota.png';
    if (key.contains('perodua')) return 'assets/images/manufacturer/perodua.png';
    if (key.contains('honda')) return 'assets/images/manufacturer/honda.png';
    if (key.contains('proton')) return 'assets/images/manufacturer/proton.png';
    if (key.contains('nissan')) return 'assets/images/manufacturer/nissan.png';
    if (key.contains('ford')) return 'assets/images/manufacturer/ford.png';
    if (key.contains('mazda')) return 'assets/images/manufacturer/mazda.png';
    if (key.contains('hyundai')) return 'assets/images/manufacturer/hyundai.png';
    if (key.contains('volkswagen'))return 'assets/images/manufacturer/volkswagen.png';
    if (key.contains('isuzu')) return 'assets/images/manufacturer/isuzu.png';
    if (key.contains('bmw')) return 'assets/images/manufacturer/bmw.png';
    return 'assets/images/manufacturer/car_generic.png';
  }
}
