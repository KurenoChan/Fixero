class Manager {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImgUrl;

  Manager({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImgUrl,
  });

  factory Manager.fromMap(Map<String, dynamic> map, String uid) {
    return Manager(
      id: uid,
      name: map['managerName'] ?? '',
      email: map['managerEmail'] ?? '',
      role: map['managerRole'] ?? '',
      profileImgUrl: map['profileImgUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'managerName': name,
      'managerEmail': email,
      'managerRole': role,
      'profileImgUrl': profileImgUrl,
    };
  }
}
