import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/inventory_management/models/item_usage.dart';


/*
********************************************************************************
OBJECTIVE: 
- Responsible for fetching and saving data to Firebase under inventory/itemUsages/.
- Does not care how we use the data — it only fetches or updates.
********************************************************************************
*/


class ItemUsageRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(
    "inventory/itemUsages",
  );

  // Get all item usages from Firebase
  Future<List<ItemUsage>> fetchAllItemUsages() async {
    final snapshot = await _db.get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return ItemUsage.fromMap(entry.value, entry.key);
    }).toList();
  }

  Future<void> addItemUsage(ItemUsage itemUsage) async {
    await _db.child(itemUsage.itemUsageNo).set(itemUsage.toMap());
  }

  Future<void> updateItemUsage(String itemUsageNo, ItemUsage updatedItemUsage) async {
    await _db.child(itemUsageNo).update(updatedItemUsage.toMap());
  }

  Future<void> deleteItemUsage(String itemUsageNo) async {
    await _db.child(itemUsageNo).remove();
  } 
}