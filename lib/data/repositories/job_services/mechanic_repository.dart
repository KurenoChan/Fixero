import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/job_management/models/mechanic_model.dart';

class MechanicRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(
    "users/mechanics",
  );

  /// 🔹 Fetch all mechanics
  Future<List<Mechanic>> fetchAllMechanics() async {
    final snapshot = await _db.get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return Mechanic.fromMap(entry.value, entry.key);
    }).toList();
  }

  /// 🔹 Fetch a specific mechanic by ID
  Future<Mechanic?> fetchMechanicById(String mechanicId) async {
    final snapshot = await _db.child(mechanicId).get();

    if (!snapshot.exists) return null;

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return Mechanic.fromMap(data, mechanicId);
  }

  /// 🔹 Fetch available mechanics only
  Future<List<Mechanic>> fetchAvailableMechanics() async {
    final allMechanics = await fetchAllMechanics();
    return allMechanics
        .where(
          (mechanic) => mechanic.mechanicStatus.toLowerCase() == 'available',
        )
        .toList();
  }

  /// 🔹 Add a new mechanic
  Future<void> addMechanic(Mechanic mechanic) async {
    await _db.child(mechanic.mechanicID).set({
      ...mechanic.toMap(), // 🔹 expands the whole Mechanic as key-value pairs
      "mechanicID":
          mechanic.mechanicID, // 🔹 explicitly adds/overrides mechanicID
    });
  }

  /// 🔹 Update mechanic status
  Future<void> updateMechanicStatus(String mechanicId, String newStatus) async {
    await _db.child(mechanicId).update({
      "mechanicStatus": newStatus,
      "updatedAt": ServerValue.timestamp,
    });
  }

  /// 🔹 Update mechanic specialty
  Future<void> updateMechanicSpecialty(
    String mechanicId,
    String newSpecialty,
  ) async {
    await _db.child(mechanicId).update({
      "mechanicSpecialty": newSpecialty,
      "updatedAt": ServerValue.timestamp,
    });
  }

  /// 🔹 Delete a mechanic
  Future<void> deleteMechanic(String mechanicId) async {
    await _db.child(mechanicId).remove();
  }

  /// 🔹 Stream for real-time updates on all mechanics
  Stream<List<Mechanic>> watchAllMechanics() {
    return _db.onValue.map((DatabaseEvent event) {
      final snapshot = event.snapshot;

      if (!snapshot.exists) return [];

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        return Mechanic.fromMap(entry.value, entry.key);
      }).toList();
    });
  }

  /// 🔹 Stream for real-time updates on a specific mechanic
  Stream<Mechanic?> watchMechanicById(String mechanicId) {
    return _db.child(mechanicId).onValue.map((DatabaseEvent event) {
      final snapshot = event.snapshot;

      if (!snapshot.exists) return null;

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      return Mechanic.fromMap(data, mechanicId);
    });
  }
}
