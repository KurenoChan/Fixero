class Manager {
  final String id;
  final String name;
  final String password;
  final String email;
  final String role;
  final String? profileImgUrl; // add this

  Manager({
    required this.id,
    required this.name,
    required this.password,
    required this.email,
    required this.role,
    this.profileImgUrl,
  });

  factory Manager.fromMap(Map<String, dynamic> map, String uid) {
    return Manager(
      id: uid,
      name: map['managerName'] ?? '',
      password: map['managerPassword'] ?? '',
      email: map['managerEmail'] ?? '',
      role: map['managerRole'] ?? '',
      profileImgUrl: map['profileImgUrl'], // make sure the key matches Firebase
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'managerName': name,
      'managerPassword': password,
      'managerEmail': email,
      'managerRole': role,
      'profileImgUrl': profileImgUrl,
    };
  }
}
