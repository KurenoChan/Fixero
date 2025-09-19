import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';

class RequestedItemRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(
    "inventory/requestedItems",
  );

  Future<List<RequestedItem>> fetchAllRequestedItems() async {
    final snapshot = await _db.get();

    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      // Cast each entry value to Map<String, dynamic>
      final value = Map<String, dynamic>.from(entry.value as Map);
      return RequestedItem.fromMap(value, entry.key);
    }).toList();
  }

  /// Fetch all items linked to a specific restock request
  Future<List<RequestedItem>> fetchItemsByRequestId(String requestId) async {
    final snapshot = await _db
        .orderByChild("requestID")
        .equalTo(requestId)
        .get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value);
      return RequestedItem.fromMap(value, entry.key);
    }).toList();
  }

  /// Add new requested item
  Future<void> addRequestedItem(RequestedItem item) async {
    await _db.child(item.requestItemID).set(item.toMap());
  }

  /// Update requested item
  Future<void> updateRequestedItem(RequestedItem item) async {
    await _db.child(item.requestItemID).update(item.toMap());
  }

  /// Delete requested item
  Future<void> deleteRequestedItem(String requestItemID) async {
    await _db.child(requestItemID).remove();
  }
}
