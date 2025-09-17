import 'package:flutter/material.dart';

class VehicleType {
  final String id;                // e.g., "car"
  final String displayName;       // e.g., "Car"
  final IconData icon;            // Material icon for the tile

  const VehicleType({
    required this.id,
    required this.displayName,
    required this.icon,
  });
}