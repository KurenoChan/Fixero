import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixero/features/job_management/models/manager_model.dart';

class ManagerDAO {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'users/managers';

  // Create a new manager
  Future<Manager> create(Manager manager) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(manager.uid)
          .set(manager.toMap());
      return manager;
    } catch (e) {
      throw Exception('Error creating manager: $e');
    }
  }

  // Get manager by UID
  Future<Manager?> getById(String uid) async {
    try {
      final doc = await _firestore.collection(collectionPath).doc(uid).get();
      if (!doc.exists) {
        return null;
      }
      return Manager.fromFirebaseSnapshot(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error getting manager: $e');
    }
  }

  // Get all managers
  Future<List<Manager>> getAll() async {
    try {
      final querySnapshot = await _firestore.collection(collectionPath).get();
      return querySnapshot.docs
          .map((doc) => Manager.fromFirebaseSnapshot(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error getting all managers: $e');
    }
  }

  // Update a manager
  Future<Manager> update(String uid, Map<String, dynamic> updateData) async {
    try {
      await _firestore.collection(collectionPath).doc(uid).update(updateData);
      return (await getById(uid))!;
    } catch (e) {
      throw Exception('Error updating manager: $e');
    }
  }

  // Delete a manager
  Future<bool> delete(String uid) async {
    try {
      await _firestore.collection(collectionPath).doc(uid).delete();
      return true;
    } catch (e) {
      throw Exception('Error deleting manager: $e');
    }
  }

  // Get managers by role
  Future<List<Manager>> getByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('managerRole', isEqualTo: role)
          .get();

      return querySnapshot.docs
          .map((doc) => Manager.fromFirebaseSnapshot(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error getting managers by role: $e');
    }
  }

  // Get manager by email
  Future<Manager?> getByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('managerEmail', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return Manager.fromFirebaseSnapshot(doc.data(), doc.id);
    } catch (e) {
      throw Exception('Error getting manager by email: $e');
    }
  }

  // Stream all managers for real-time updates
  Stream<List<Manager>> streamAll() {
    return _firestore
        .collection(collectionPath)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Manager.fromFirebaseSnapshot(doc.data(), doc.id))
              .toList(),
        );
  }

  // Stream manager by ID for real-time updates
  Stream<Manager?> streamById(String uid) {
    return _firestore
        .collection(collectionPath)
        .doc(uid)
        .snapshots()
        .map(
          (doc) => doc.exists
              ? Manager.fromFirebaseSnapshot(doc.data()!, doc.id)
              : null,
        );
  }
}
