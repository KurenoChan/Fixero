class Supplier {
  final String supplierID;
  final String supplierName;
  final String supplierEmail;
  final String supplierTel;
  final String address1;
  final String address2;
  final String postalCode;
  final String street;
  final String city;
  final String state;
  final String country;

  Supplier({
    required this.supplierID,
    required this.supplierName,
    required this.supplierEmail,
    required this.supplierTel,
    required this.address1,
    required this.address2,
    required this.postalCode,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
  });

  factory Supplier.fromMap(Map<dynamic, dynamic> map, String id) {
    return Supplier(
      supplierID: id,
      supplierName: map['supplierName'] ?? '',
      supplierEmail: map['supplierEmail'] ?? '',
      supplierTel: map['supplierTel'] ?? '',
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      postalCode: map['postalCode'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierName': supplierName,
      'supplierEmail': supplierEmail,
      'supplierTel': supplierTel,
      'address1': address1,
      'address2': address2,
      'postalCode': postalCode,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
    };
  }
}