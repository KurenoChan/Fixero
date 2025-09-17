import 'package:flutter/material.dart';
import '../models/vehicle_type.dart';

/// Controller for the Vehicles home screen:
class VehicleTypesController extends ChangeNotifier {
  VehicleTypesController({void Function(VehicleType type)? onSelectType})
      : _onSelectType = onSelectType;

  final void Function(VehicleType type)? _onSelectType;

  // Base list of types shown (you can later fetch from RTDB if desired).
  static const List<VehicleType> _allTypes = [
    VehicleType(id: 'car',   displayName: 'Car',   icon: Icons.directions_car_filled),
    VehicleType(id: 'bike',  displayName: 'Bike',  icon: Icons.motorcycle),
    VehicleType(id: 'van',   displayName: 'Van',   icon: Icons.airport_shuttle),
    VehicleType(id: 'truck', displayName: 'Truck', icon: Icons.local_shipping),
  ];

  String _query = '';
  String get query => _query;

  List<VehicleType> get filteredTypes {
    if (_query.trim().isEmpty) return _allTypes;
    final q = _query.toLowerCase();
    return _allTypes
        .where((t) => t.displayName.toLowerCase().contains(q) || t.id.contains(q))
        .toList(growable: false);
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  /// Call when a type tile is tapped. You’ll wire this to navigation.
  void selectType(VehicleType type) {
    _onSelectType?.call(type);
  }
}
