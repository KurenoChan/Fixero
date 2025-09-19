class Vehicle {
  final String plateNo;
  final String type;
  final String model;
  final String colorName;
  final String manufacturer;
  final int year;
  final String ownerId;
  final String? ownerName;
  final String? ownerGender;
  final String? vin;
  final String? make;
  final String? imageUrl;
  final int? peakPowerKw;
  final int? speedLimiter;
  final int? mileage;
  final int? fuelTank;

  const Vehicle({
    required this.plateNo,
    required this.type,
    required this.model,
    required this.colorName,
    required this.manufacturer,
    required this.year,
    required this.ownerId,
    this.ownerName,
    this.ownerGender,
    this.vin,
    this.make,
    this.imageUrl,
    this.peakPowerKw,
    this.speedLimiter,
    this.mileage,
    this.fuelTank,
  });

  Vehicle copyWith({
    String? plateNo,
    String? type,
    String? model,
    String? colorName,
    String? manufacturer,
    int? year,
    String? ownerId,
    String? ownerName,
    String? ownerGender,
    String? vin,
    String? make,
    String? imageUrl,
    int? peakPowerKw,
    int? speedLimiter,
    int? mileage,
    int? fuelTank,
  }) {
    return Vehicle(
      plateNo: plateNo ?? this.plateNo,
      type: type ?? this.type,
      model: model ?? this.model,
      colorName: colorName ?? this.colorName,
      manufacturer: manufacturer ?? this.manufacturer,
      year: year ?? this.year,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerGender: ownerGender ?? this.ownerGender,
      vin: vin ?? this.vin,
      make: make ?? this.make,
      imageUrl: imageUrl ?? this.imageUrl,
      peakPowerKw: peakPowerKw ?? this.peakPowerKw,
      speedLimiter: speedLimiter ?? this.speedLimiter,
      mileage: mileage ?? this.mileage,
      fuelTank: fuelTank ?? this.fuelTank,
    );
  }

  Map<String, dynamic> toMap({bool keyAsPlate = true}) {
    return {
      'plateNo': plateNo,
      'type': type,
      'model': model,
      'colorName': colorName,
      'manufacturer': manufacturer,
      'year': year,
      'ownerID': ownerId,
      if (ownerName != null) 'ownerName': ownerName,
      if (ownerGender != null) 'ownerGender': ownerGender,
      if (vin != null) 'vin': vin,
      if (make != null) 'make': make,
      if (imageUrl != null) 'vehicleImageUrl': imageUrl,
      if (peakPowerKw != null) 'peakPowerKw': peakPowerKw,
      if (speedLimiter != null) 'speedLimiter': speedLimiter,
      if (mileage != null) 'mileage': mileage,
      if (fuelTank != null) 'fuelTank': fuelTank,
    };
  }

  // ===== Helpers to construct from RTDB =====
  static String _s(Object? v) => (v ?? '').toString();

  static int? _toInt(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  /// Build from a map, using `fallbackKey` as the plateNo if not found in map.
  factory Vehicle.fromMap(Map<dynamic, dynamic> m, {String? fallbackKey}) {
    final plate = _s(m['plateNo']).isNotEmpty ? _s(m['plateNo']) : (fallbackKey ?? '');

    return Vehicle(
      plateNo: plate,
      type: _s(m['type']),
      model: _s(m['model']),
      colorName: _s(m['colorName']),
      manufacturer: _s(m['manufacturer']),
      year: int.tryParse(_s(m['year'])) ?? 0,
      ownerId: _s(m['ownerID']),
      ownerName: _s(m['ownerName']).isEmpty ? null : _s(m['ownerName']),
      ownerGender: _s(m['ownerGender']).isEmpty ? null : _s(m['ownerGender']),
      vin: _s(m['vin']).isEmpty ? null : _s(m['vin']),
      make: _s(m['make']).isEmpty ? null : _s(m['make']),
      imageUrl: _s(m['vehicleImageUrl']).isNotEmpty
          ? _s(m['vehicleImageUrl'])
          : (_s(m['imageUrl']).isEmpty ? null : _s(m['imageUrl'])),
      peakPowerKw: _toInt(m['peakPowerKw']),
      speedLimiter: _toInt(m['speedLimiter']),
      mileage: _toInt(m['mileage']),
      fuelTank: _toInt(m['fuelTank']),
    );
  }
}
