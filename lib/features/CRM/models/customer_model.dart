class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final String dob;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.dob,
  });

  factory Customer.fromMap(Map<dynamic, dynamic> map, String id) {
    return Customer(
      id: id,
      name: _formatName(map['custName'] ?? ''),
      email: map['custEmail'] ?? '',
      phone: map['custTel'] ?? '',
      address:
      "${map['address1'] ?? ''}, ${map['address2'] ?? ''}, ${map['city'] ?? ''}, ${map['state'] ?? ''}, ${map['postalCode'] ?? ''}, ${map['country'] ?? ''}",
      gender: map['gender'] ?? 'Not specified',
      dob: map['dob'] ?? 'Not specified',
    );
  }

  /// 🔹 Helper to clean and format the name
  static String _formatName(String raw) {
    // remove digits
    String noDigits = raw.replaceAll(RegExp(r'\d'), '');
    // replace underscores/dots with spaces
    String spaced = noDigits.replaceAll(RegExp(r'[_\.]+'), ' ');
    // capitalize each word
    return spaced
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}
