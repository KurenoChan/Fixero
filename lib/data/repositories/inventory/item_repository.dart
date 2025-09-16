import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/utils/generators/id_generator.dart';
import '../../../features/inventory_management/models/item.dart';

/*
********************************************************************************
OBJECTIVE: 
- Responsible for fetching and saving data to Firebase under inventory/items/.
- Does not care how we use the data — it only fetches or updates.
********************************************************************************
*/

class ItemRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(
    "inventory/items",
  );

  // Get all items from Firebase
  Future<List<Item>> fetchAllItems() async {
    final snapshot = await _db.get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return Item.fromMap(entry.value, entry.key);
    }).toList();
  }

  Future<void> addItem(Item item) async {
    // Generate a custom ID
    final String newItemID = IDGenerator.generateItemID();

    // Save under your own ID instead of push()
    await _db.child(newItemID).set({
      ...item.toMap(),      // 🔹 expands the whole Item as key-value pairs
      "itemID": newItemID,  // 🔹 explicitly adds/overrides itemID
    });
  }

  Future<void> updateItem(String itemId, Item updatedItem) async {
    await _db.child(itemId).update(updatedItem.toMap());
  }

  Future<void> deleteItem(String itemId) async {
    await _db.child(itemId).remove();
  }
}
