import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/job_management/models/manager_model.dart';

class ManagerService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<Manager?> getManagerById(String uid) async {
    try {
      final snapshot = await _db.child("users/managers/$uid").get();
      print("📌 Fetching manager at path: users/managers/$uid");
      print("📌 Snapshot value: ${snapshot.value}");

      if (snapshot.exists && snapshot.value is Map) {
        return Manager.fromMap(
          uid,
          Map<String, dynamic>.from(snapshot.value as Map),
        );
      }
      return null;
    } catch (e) {
      print("Error fetching manager: $e");
      return null;
    }
  }

  Future<List<Manager>> getAllManagers() async {
    try {
      final snapshot = await _db.child("users/managers").get();
      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value;

        if (rawData is Map) {
          final data = Map<String, dynamic>.from(rawData);
          return data.entries.map((e) {
            return Manager.fromMap(e.key, Map<String, dynamic>.from(e.value));
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching managers: $e");
      return [];
    }
  }

  Future<Manager?> createManager(Manager manager) async {
    try {
      await _db.child("users/managers/${manager.uid}").set(manager.toMap());
      return manager;
    } catch (e) {
      print("Error creating manager: $e");
      return null;
    }
  }

  Future<Manager?> updateManager(
    String uid,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await _db.child("users/managers/$uid").update(updateData);
      final snapshot = await _db.child("users/managers/$uid").get();

      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value;
        if (rawData is Map) {
          return Manager.fromMap(uid, Map<String, dynamic>.from(rawData));
        }
      }
      return null;
    } catch (e) {
      print("Error updating manager: $e");
      return null;
    }
  }

  Future<bool> deleteManager(String uid) async {
    try {
      await _db.child("users/managers/$uid").remove();
      return true;
    } catch (e) {
      print("Error deleting manager: $e");
      return false;
    }
  }

  // 🔥 Streams
  Stream<Manager?> streamManagerById(String uid) {
    return _db.child("users/managers/$uid").onValue.map((event) {
      final rawData = event.snapshot.value;
      if (rawData != null && rawData is Map) {
        return Manager.fromMap(uid, Map<String, dynamic>.from(rawData));
      }
      return null;
    });
  }

  Stream<List<Manager>> streamAllManagers() {
    return _db.child("users/managers").onValue.map((event) {
      final rawData = event.snapshot.value;
      if (rawData != null && rawData is Map) {
        final data = Map<String, dynamic>.from(rawData);
        return data.entries.map((e) {
          return Manager.fromMap(e.key, Map<String, dynamic>.from(e.value));
        }).toList();
      }
      return [];
    });
  }
}
