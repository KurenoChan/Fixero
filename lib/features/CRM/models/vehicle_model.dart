// vehicle_model.dart
class Vehicle {
  final String plateNumber;
  final String color;
  final String manufacturer;
  final String model;
  final String type;
  final int year;
  final String ownerId;

  Vehicle({
    required this.plateNumber,
    required this.color,
    required this.manufacturer,
    required this.model,
    required this.type,
    required this.year,
    required this.ownerId,
  });

  factory Vehicle.fromMap(Map<dynamic, dynamic> map, String id) {
    return Vehicle(
      plateNumber: id,
      color: map['color'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      model: map['model'] ?? '',
      type: map['type'] ?? '',
      year: map['year'] ?? 0,
      ownerId: map['ownerID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'manufacturer': manufacturer,
      'model': model,
      'type': type,
      'year': year,
      'ownerID': ownerId,
    };
  }
}
