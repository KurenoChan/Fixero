import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';

class RestockRequestRepository {
  final DatabaseReference _db =
      FirebaseDatabase.instance.ref("inventory/restockRequests");

  Future<List<RestockRequest>> fetchAllRequests() async {
    final snapshot = await _db.get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value);
      return RestockRequest.fromMap(value, entry.key);
    }).toList();
  }

  Future<RestockRequest?> getRequestById(String requestId) async {
    final snapshot = await _db.child(requestId).get();

    if (!snapshot.exists) return null;

    final data = snapshot.value as Map<dynamic, dynamic>;
    return RestockRequest.fromMap(
      Map<String, dynamic>.from(data),
      requestId,
    );
  }

  Future<void> addRequest(RestockRequest request) async {
    await _db.child(request.requestID).set(request.toMap());
  }

  Future<void> updateRequest(RestockRequest request) async {
    await _db.child(request.requestID).update(request.toMap());
  }

  Future<void> deleteRequest(String requestId) async {
    await _db.child(requestId).remove();
  }
}
