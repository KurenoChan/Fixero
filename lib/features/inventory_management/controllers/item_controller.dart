import 'package:fixero/data/dao/inventory/item_dao.dart';
import 'package:flutter/foundation.dart';
import '../models/item.dart';

class ItemController extends ChangeNotifier {
  final ItemDAO _dao = ItemDAO();

  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🔹 Load all items from Firebase once
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _dao.getAllItems();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Sync methods for UI to read cached items
  List<String> getCategoriesSync() {
    return _items.map((e) => e.itemCategory).toSet().toList();
  }

  List<String> getSubCategoriesSync(String category) {
    return _items
        .where((e) => e.itemCategory == category)
        .map((e) => e.itemSubCategory)
        .toSet()
        .toList();
  }

  List<Item> getItemsBySubCategorySync(String subCategory) {
    return _items.where((e) => e.itemSubCategory == subCategory).toList();
  }

  Item? getFirstItemBySubCategorySync(String subCategory) {
    try {
      return _items.firstWhere((e) => e.itemSubCategory == subCategory);
    } catch (e) {
      return null;
    }
  }

  /// 🔹 Low stock items
  List<Item> get lowStockItems =>
      _items.where((e) => e.stockQuantity <= e.lowStockThreshold).toList();

  /// 🔹 Update item
  Future<void> updateItem(Item updatedItem) async {
    try {
      await _dao.updateItem(updatedItem);

      final index = _items.indexWhere((i) => i.itemID == updatedItem.itemID);
      if (index != -1) {
        _items[index] = updatedItem;
      } else {
        _items.add(updatedItem);
      }

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 🔹 Get item by ID
  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.itemID == id);
    } catch (e) {
      return null;
    }
  }
}