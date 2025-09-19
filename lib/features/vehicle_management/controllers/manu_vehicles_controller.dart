import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/vehicle.dart';

enum VehicleSort {
  plateAsc,
  plateDesc,
  ownerAsc,
  ownerDesc,
  modelAsc,
  modelDesc,
}

class ManufacturerVehiclesController extends ChangeNotifier {
  ManufacturerVehiclesController(this.manufacturer);

  final String manufacturer;

  final List<Vehicle> _all = [];
  String _query = '';
  VehicleSort _sort = VehicleSort.plateAsc;

  StreamSubscription<DatabaseEvent>? _vehSub;

  List<Vehicle> get vehicles {
    Iterable<Vehicle> list = _all;
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where(
        (v) =>
            v.plateNo.toLowerCase().contains(q) ||
            (v.ownerName ?? '').toLowerCase().contains(q) ||
            v.model.toLowerCase().contains(q),
      );
    }
    final l = list.toList();
    _sortList(l);
    return UnmodifiableListView(l);
  }

  VehicleSort get sort => _sort;
  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void toggleSort() {
    switch (_sort) {
      case VehicleSort.plateAsc:
        _sort = VehicleSort.plateDesc;
        break;
      case VehicleSort.plateDesc:
        _sort = VehicleSort.ownerAsc;
        break;
      case VehicleSort.ownerAsc:
        _sort = VehicleSort.ownerDesc;
        break;
      case VehicleSort.ownerDesc:
        _sort = VehicleSort.modelAsc;
        break;
      case VehicleSort.modelAsc:
        _sort = VehicleSort.modelDesc;
        break;
      case VehicleSort.modelDesc:
        _sort = VehicleSort.plateAsc;
        break;
    }
    notifyListeners();
  }

  void _sortList(List<Vehicle> l) {
    int cmp(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());
    switch (_sort) {
      case VehicleSort.plateAsc:
        l.sort((a, b) => cmp(a.plateNo, b.plateNo));
        break;
      case VehicleSort.plateDesc:
        l.sort((a, b) => cmp(b.plateNo, a.plateNo));
        break;
      case VehicleSort.ownerAsc:
        l.sort((a, b) => cmp(a.ownerName ?? '', b.ownerName ?? ''));
        break;
      case VehicleSort.ownerDesc:
        l.sort((a, b) => cmp(b.ownerName ?? '', a.ownerName ?? ''));
        break;
      case VehicleSort.modelAsc:
        l.sort((a, b) => cmp(a.model, b.model));
        break;
      case VehicleSort.modelDesc:
        l.sort((a, b) => cmp(b.model, a.model));
        break;
    }
  }

  void setSort(VehicleSort s) {
    _sort = s;
    notifyListeners();
  }

  Future<void> listen() async {
    await _vehSub?.cancel();

    final vehRef = FirebaseDatabase.instance.ref('vehicles');
    _vehSub = vehRef.onValue.listen((event) async {
      final snap = event.snapshot;
      final List<Vehicle> base = [];
      final Set<String> ownerIds = {};

      for (final c in snap.children) {
        final data = c.value;
        if (data is Map) {
          final v = Vehicle.fromMap(data, fallbackKey: c.key);
          if (v.manufacturer.toLowerCase().trim() ==
              manufacturer.toLowerCase().trim()) {
            base.add(v);
            if (v.ownerId.trim().isNotEmpty) ownerIds.add(v.ownerId.trim());
          }
        }
      }

      // load customers (users/customers) and index by both key and custID
      final Map<String, Map<dynamic, dynamic>> ownersById = {};
      if (ownerIds.isNotEmpty) {
        final custSnap = await FirebaseDatabase.instance
            .ref('users/customers')
            .get();
        if (custSnap.exists) {
          for (final c in custSnap.children) {
            if (c.value is! Map) continue;
            final map = Map<dynamic, dynamic>.from(c.value as Map);
            final keyId = (c.key ?? '').trim();
            final fieldId = (map['custID'] ?? '').toString().trim();
            if (keyId.isNotEmpty) ownersById[keyId] = map;
            if (fieldId.isNotEmpty) ownersById[fieldId] = map;
          }
        }
      }

      final joined = base.map((v) {
        final o = ownersById[v.ownerId.trim()];
        return v.copyWith(
          ownerName: (o?['custName'] ?? '').toString(),
          ownerGender: (o?['gender'] ?? 'unknown').toString().toLowerCase(),
        );
      }).toList();

      if (kDebugMode) {
        debugPrint('[Vehicles:$manufacturer] items=${joined.length}');
        if (joined.isNotEmpty) {
          final a = joined.first;
          debugPrint(
            ' e.g. plate=${a.plateNo}, ownerId=${a.ownerId}, owner=${a.ownerName}, model=${a.model}',
          );
        }
      }

      _all
        ..clear()
        ..addAll(joined);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _vehSub?.cancel();
    super.dispose();
  }

  static Color colorFromName(String name) {
    final k = name.toLowerCase();
    if (k.contains('red')) return const Color(0xFFFF6B6B);
    if (k.contains('blue')) return const Color(0xFF4D9DE0);
    if (k.contains('silver') || k.contains('grey') || k.contains('gray'))return const Color(0xFFB0B0B0);
    if (k.contains('black')) return const Color(0xFF4A4A4A);
    if (k.contains('white')) return const Color(0xFFEDEDED);
    if (k.contains('maroon')) return const Color(0xFF8B1E3F);
    if (k.contains('green')) return const Color(0xFF3CB371);
    if (k.contains('brown')) return const Color(0xFF8D6E63);
    if (k.contains('orange')) return const Color(0xFFFFA726);
    return const Color(0xFFBDBDBD);
  }
}
