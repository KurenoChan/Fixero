class Mechanic {
  final String mechanicID;
  final String mechanicName;
  final String mechanicEmail;
  final String mechanicTel;
  final String mechanicSpecialty;
  final String mechanicStatus;
  final DateTime joinedDate;

  Mechanic({
    required this.mechanicID,
    required this.mechanicName,
    required this.mechanicEmail,
    required this.mechanicTel,
    required this.mechanicSpecialty,
    required this.mechanicStatus,
    required this.joinedDate,
  });

  /// 🔹 Factory constructor from Firebase Map data
  factory Mechanic.fromMap(Map<dynamic, dynamic> data, String mechanicId) {
    return Mechanic(
      mechanicID: mechanicId,
      mechanicName: data['mechanicName']?.toString() ?? 'Unknown Mechanic',
      mechanicEmail: data['mechanicEmail']?.toString() ?? '',
      mechanicTel: data['mechanicTel']?.toString() ?? '',
      mechanicSpecialty:
          data['mechanicSpecialty']?.toString() ?? 'General Repair',
      mechanicStatus: data['mechanicStatus']?.toString() ?? 'Unknown',
      joinedDate: DateTime.parse(
        data['joinedDate']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// 🔹 Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'mechanicName': mechanicName,
      'mechanicEmail': mechanicEmail,
      'mechanicTel': mechanicTel,
      'mechanicSpecialty': mechanicSpecialty,
      'mechanicStatus': mechanicStatus,
      'joinedDate': joinedDate.toIso8601String(),
    };
  }

  /// 🔹 CopyWith method for immutable updates
  Mechanic copyWith({
    String? mechanicID,
    String? mechanicName,
    String? mechanicEmail,
    String? mechanicTel,
    String? mechanicSpecialty,
    String? mechanicStatus,
    DateTime? joinedDate,
  }) {
    return Mechanic(
      mechanicID: mechanicID ?? this.mechanicID,
      mechanicName: mechanicName ?? this.mechanicName,
      mechanicEmail: mechanicEmail ?? this.mechanicEmail,
      mechanicTel: mechanicTel ?? this.mechanicTel,
      mechanicSpecialty: mechanicSpecialty ?? this.mechanicSpecialty,
      mechanicStatus: mechanicStatus ?? this.mechanicStatus,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  /// 🔹 Helper getter for compatibility with controller
  String get id => mechanicID;

  /// 🔹 Convert specialty string to list
  List<String> get specialties {
    return mechanicSpecialty.split(',').map((s) => s.trim()).toList();
  }

  /// 🔹 Check if mechanic is available
  bool get isAvailable => mechanicStatus.toLowerCase() == 'available';

  /// 🔹 Get formatted join date
  String get formattedJoinDate {
    return '${joinedDate.day}/${joinedDate.month}/${joinedDate.year}';
  }

  /// 🔹 Get initials for avatar
  String get initials {
    final names = mechanicName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (mechanicName.isNotEmpty) {
      return mechanicName.substring(0, 1).toUpperCase();
    }
    return 'M';
  }

  /// 🔹 Equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mechanic && other.mechanicID == mechanicID;
  }

  @override
  int get hashCode => mechanicID.hashCode;

  /// 🔹 String representation
  @override
  String toString() {
    return 'Mechanic('
        'id: $mechanicID, '
        'name: $mechanicName, '
        'email: $mechanicEmail, '
        'status: $mechanicStatus, '
        'specialty: $mechanicSpecialty'
        ')';
  }

  /// 🔹 Create a new mechanic with default values
  factory Mechanic.createNew({
    required String name,
    required String email,
    String? tel,
    String specialty = 'General Repair',
    String status = 'Available',
  }) {
    return Mechanic(
      mechanicID: DateTime.now().millisecondsSinceEpoch.toString(),
      mechanicName: name,
      mechanicEmail: email,
      mechanicTel: tel ?? '',
      mechanicSpecialty: specialty,
      mechanicStatus: status,
      joinedDate: DateTime.now(),
    );
  }

  /// 🔹 Check if mechanic has specific specialty
  bool hasSpecialty(String specialty) {
    return specialties.any((s) => s.toLowerCase() == specialty.toLowerCase());
  }

  /// 🔹 Get status color for UI
  String get statusColor {
    switch (mechanicStatus.toLowerCase()) {
      case 'available':
        return 'green';
      case 'busy':
        return 'orange';
      case 'offline':
        return 'gray';
      case 'on_break':
        return 'blue';
      default:
        return 'red';
    }
  }

  /// 🔹 Get status icon for UI
  String get statusIcon {
    switch (mechanicStatus.toLowerCase()) {
      case 'available':
        return '✅';
      case 'busy':
        return '🛠️';
      case 'offline':
        return '🔴';
      case 'on_break':
        return '☕';
      default:
        return '❓';
    }
  }
}
