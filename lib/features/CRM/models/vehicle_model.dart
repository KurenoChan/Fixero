// models/vehicle_model.dart
class Vehicle {
  final String plateNumber;
  final String type;
  final String model;
  final String color;
  final String manufacturer;
  final int year;
  final String ownerID;

  Vehicle({
    required this.plateNumber,
    required this.type,
    required this.model,
    required this.color,
    required this.manufacturer,
    required this.year,
    required this.ownerID,
  });

  factory Vehicle.fromMap(String plate, Map<String, dynamic> data) {
    return Vehicle(
      plateNumber: plate,
      type: data['type'] ?? '',
      model: data['model'] ?? '',
      color: data['color'] ?? '',
      manufacturer: data['manufacturer'] ?? '',
      year: data['year'] ?? 0,
      ownerID: data['ownerID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "model": model,
      "color": color,
      "manufacturer": manufacturer,
      "year": year,
      "ownerID": ownerID,
    };
  }
}
