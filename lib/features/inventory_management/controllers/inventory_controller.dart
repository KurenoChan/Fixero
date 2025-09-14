import 'package:fixero/data/dao/inventory/item_dao.dart';
import '../models/item_model.dart';

class InventoryController {
  final ItemDAO _dao = ItemDAO();

  Future<List<String>> getCategories() async {
    final items = await _dao.getAllItems();
    return items.map((e) => e.itemCategory).toSet().toList();
  }

  Future<List<String>> getSubCategories(String category) async {
    final items = await _dao.getItemsByCategory(category);
    return items.map((e) => e.itemSubCategory).toSet().toList();
  }

  Future<List<Item>> getItems(String subCategory) async {
    final items = await _dao.getAllItems();
    return items.where((e) => e.itemSubCategory == subCategory).toList();
  }

  /// 🔹 NEW: get first item in subcategory for preview image
  Future<Item?> getFirstItemBySubCategory(String subCategory) async {
    final items = await getItems(subCategory);
    return items.isNotEmpty ? items.first : null;
  }
}
