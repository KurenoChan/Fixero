// models/customer_model.dart
class Customer {
  final String custID;
  String custName;
  String custEmail;
  String custTel;
  String gender;
  String dob;
  String address1;
  String address2;
  String postalCode;
  String street;
  String city;
  String state;
  String country;

  Customer({
    required this.custID,
    required this.custName,
    required this.custEmail,
    required this.custTel,
    required this.gender,
    required this.dob,
    required this.address1,
    required this.address2,
    required this.postalCode,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
  });

  factory Customer.fromMap(String id, Map<String, dynamic> data) {
    return Customer(
      custID: id,
      custName: data['custName'] ?? '',
      custEmail: data['custEmail'] ?? '',
      custTel: data['custTel'] ?? '',
      gender: data['gender'] ?? '',
      dob: data['dob'] ?? '',
      address1: data['address1'] ?? '',
      address2: data['address2'] ?? '',
      postalCode: data['postalCode'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "custName": custName,
      "custEmail": custEmail,
      "custTel": custTel,
      "gender": gender,
      "dob": dob,
      "address1": address1,
      "address2": address2,
      "postalCode": postalCode,
      "street": street,
      "city": city,
      "state": state,
      "country": country,
    };
  }
}
