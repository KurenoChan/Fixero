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
    );
  }

  static String _readStr(Map<dynamic, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (m.containsKey(k) && m[k] != null) {
        final v = m[k].toString().trim();
        if (v.isNotEmpty) return v;
      }
    }
    return '';
  }

  /// NEW: `fallbackKey` lets us use the node key (e.g. "ABC1234") when the map has no plateNo field.
  static Vehicle fromMap(Map<dynamic, dynamic> m, {String? fallbackKey}) {
    final plate = _readStr(m, ['plateNo', 'plate', 'plate_no', 'PlateNo', 'plateNumber']);
    final typ   = _readStr(m, ['type', 'vehicleType', 'Type']);
    final mdl   = _readStr(m, ['model', 'Model']);
    final col   = _readStr(m, ['color', 'colour', 'Color']);
    final man   = _readStr(m, ['manufacturer', 'make', 'Manufacturer']);
    final yrStr = _readStr(m, ['year', 'Year']);
    final own   = _readStr(m, ['ownerID', 'ownerId', 'custID', 'customerId']);

    return Vehicle(
      plateNo: plate.isNotEmpty ? plate : (fallbackKey ?? ''),
      type: typ,
      model: mdl,
      colorName: col,
      manufacturer: man,
      year: int.tryParse(yrStr) ?? 0,
      ownerId: own,
    );
  }
}
