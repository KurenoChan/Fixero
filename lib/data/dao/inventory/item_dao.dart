import '../../../features/inventory_management/models/item_model.dart';
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

  Future<List<Item>> getLowStockItems() async {
    final items = await _repo.fetchAllItems();
    return items.where((item) => item.stockQuantity <= item.lowStockThreshold).toList();
  }

  Future<List<Item>> getItemsByCategory(String category) async {
    final items = await _repo.fetchAllItems();
    return items.where((item) => item.itemCategory == category).toList();
  }

  Future<List<Item>> getItemsBySubcategory(String category, String subcategory) async {
    final items = await _repo.fetchAllItems();
    return items.where((item) => item.itemCategory == category && item.itemSubCategory == subcategory).toList();
  }
}