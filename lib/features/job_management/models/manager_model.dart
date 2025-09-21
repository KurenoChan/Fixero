class Manager {
  final String uid;
  final String managerName;
  final String managerEmail;
  final String managerRole;
  final String? profileImgUrl;

  Manager({
    required this.uid,
    required this.managerName,
    required this.managerEmail,
    required this.managerRole,
    this.profileImgUrl,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'managerName': managerName,
      'managerEmail': managerEmail,
      'managerRole': managerRole,
      'profileImgUrl': profileImgUrl,
    };
  }

  // Create from Map
  factory Manager.fromMap(String uid, Map<String, dynamic> map) {
    return Manager(
      uid: uid,
      managerName: map['managerName'] ?? '',
      managerEmail: map['managerEmail'] ?? '',
      managerRole: map['managerRole'] ?? '',
      profileImgUrl: map['profileImgUrl'],
    );
  }

  // Create from Firebase snapshot
  factory Manager.fromFirebaseSnapshot(
    Map<String, dynamic> snapshot,
    String uid,
  ) {
    return Manager(
      uid: uid,
      managerName: snapshot['managerName'] ?? '',
      managerEmail: snapshot['managerEmail'] ?? '',
      managerRole: snapshot['managerRole'] ?? '',
      profileImgUrl: snapshot['profileImgUrl'],
    );
  }

  // Copy with method for updates
  Manager copyWith({
    String? managerName,
    String? managerEmail,
    String? managerRole,
    String? profileImgUrl,
  }) {
    return Manager(
      uid: uid,
      managerName: managerName ?? this.managerName,
      managerEmail: managerEmail ?? this.managerEmail,
      managerRole: managerRole ?? this.managerRole,
      profileImgUrl: profileImgUrl ?? this.profileImgUrl,
    );
  }

  @override
  String toString() {
    return 'Manager(uid: $uid, managerName: $managerName, managerEmail: $managerEmail, managerRole: $managerRole)';
  }
}
