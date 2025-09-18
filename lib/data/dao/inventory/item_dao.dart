import '../../../features/inventory_management/models/item.dart';
import '../../repositories/inventory/item_repository.dart';

/*
********************************************************************************
OBJECTIVE: 
- Uses the repository to get raw items.
- Does not care how we use the data — it only fetches or updates.
********************************************************************************
*/

class ItemDAO {
  final ItemRepository _repo = ItemRepository();

  Future<List<Item>> getAllItems() async {
    return await _repo.fetchAllItems();
  }

  Future<void> addItem(Item item) async {
    await _repo.addItem(item);
  }

  Future<void> updateItem(Item item) async {
    await _repo.updateItem(item.itemID, item); // pass itemID explicitly
  }

  Future<void> deleteItem(Item item) async {
    await _repo.deleteItem(item);
  }
}
