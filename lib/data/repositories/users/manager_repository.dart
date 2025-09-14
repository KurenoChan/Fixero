import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/authentication/models/manager.dart';

class ManagerRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    "users/managers",
  );

  Future<Manager?> getManager(String uid) async {
    final snapshot = await _dbRef.child(uid).get();
    if (snapshot.exists) {
      return Manager.fromMap(
        Map<String, dynamic>.from(snapshot.value as Map),
        uid,
      );
    }
    return null;
  }

  Future<void> updateManager(Manager manager) async {
    await _dbRef.child(manager.id).set(manager.toMap());
  }
}
