import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';

class RequestedItemRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(
    "inventory/requestedItems",
  );

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
  Future<void> addItem(RequestedItem item) async {
    await _db.child(item.requestItemId).set(item.toMap());
  }

  /// Update requested item
  Future<void> updateItem(RequestedItem item) async {
    await _db.child(item.requestItemId).update(item.toMap());
  }

  /// Delete requested item
  Future<void> deleteItem(String requestItemId) async {
    await _db.child(requestItemId).remove();
  }
}
