class CarModel {
  /// Manufacturer name, e.g. "Toyota", "Honda"
  final String name;

  /// Logo asset path for this manufacturer
  final String imagePath;

  /// Total number of vehicles for this manufacturer
  final int count;

  const CarModel({
    required this.name,
    required this.imagePath,
    required this.count,
  });

  CarModel copyWith({String? name, String? imagePath, int? count}) {
    return CarModel(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      count: count ?? this.count,
    );
  }
}
