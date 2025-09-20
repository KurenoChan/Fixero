class Vehicle {
  final String plateNo;
  final String type;
  final String model;
  final String color;
  final String manufacturer;
  final String year;
  final String ownerID;
  final String vin;
  final String make;
  final String peakPowerKw;
  final String speedLimiter;
  final String mileage;
  final String fuelTank;
  final String vehicleImageUrl;

  Vehicle({
    required this.plateNo,
    required this.type,
    required this.model,
    required this.color,
    required this.manufacturer,
    required this.year,
    required this.ownerID,
    required this.vin,
    required this.make,
    required this.peakPowerKw,
    required this.speedLimiter,
    required this.mileage,
    required this.fuelTank,
    required this.vehicleImageUrl,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map, String plateNo) {
    return Vehicle(
      plateNo: plateNo,
      type: _convertToString(map['type']),
      model: _convertToString(map['model']),
      color: _convertToString(map['color']),
      manufacturer: _convertToString(map['manufacturer']),
      year: _convertToString(map['year']),
      ownerID: _convertToString(map['ownerID']),
      vin: _convertToString(map['vin']),
      make: _convertToString(map['make']),
      peakPowerKw: _convertToString(map['peakPowerKw']),
      speedLimiter: _convertToString(map['speedLimiter']),
      mileage: _convertToString(map['mileage']),
      fuelTank: _convertToString(map['fuelTank']),
      vehicleImageUrl: _convertToString(map['vehicleImageUrl']),
    );
  }

  // Helper method to convert any type to String
  static String _convertToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'model': model,
      'color': color,
      'manufacturer': manufacturer,
      'year': year,
      'ownerID': ownerID,
      'vin': vin,
      'make': make,
      'peakPowerKw': peakPowerKw,
      'speedLimiter': speedLimiter,
      'mileage': mileage,
      'fuelTank': fuelTank,
      'vehicleImageUrl': vehicleImageUrl,
    };
  }

  @override
  String toString() {
    return 'Vehicle(plateNo: $plateNo, model: $model, year: $year, ownerID: $ownerID)';
  }
}
