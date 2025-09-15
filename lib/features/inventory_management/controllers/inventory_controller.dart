import 'package:fixero/data/dao/inventory/item_dao.dart';
import 'package:flutter/foundation.dart';
import '../models/item_model.dart';

class InventoryController extends ChangeNotifier {
  final ItemDAO _dao = ItemDAO();

  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all items from Firebase once
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

  // Category list
 Future<List<String>> getCategories() async {
    return Future.value(_items.map((e) => e.itemCategory).toSet().toList());
  }

  Future<List<String>> getSubCategories(String category) async {
    final subCats = _items
        .where((e) => e.itemCategory == category)
        .map((e) => e.itemSubCategory)
        .toSet()
        .toList();
    return Future.value(subCats);
  }

  Future<List<Item>> getItems(String subCategory) async {
    final items = _items.where((e) => e.itemSubCategory == subCategory).toList();
    return Future.value(items);
  }

  Future<Item?> getFirstItemBySubCategory(String subCategory) async {
    try {
      final item = _items.firstWhere((e) => e.itemSubCategory == subCategory);
      return Future.value(item);
    } catch (e) {
      return Future.value(null);
    }
  }

  // Low stock items
  List<Item> get lowStockItems =>
      _items.where((e) => e.stockQuantity <= e.lowStockThreshold).toList();

  // Future<List<String>> getCategories() async {
  //   final items = await _dao.getAllItems();
  //   return items.map((e) => e.itemCategory).toSet().toList();
  // }

  // Future<List<String>> getSubCategories(String category) async {
  //   final items = await _dao.getItemsByCategory(category);
  //   return items.map((e) => e.itemSubCategory).toSet().toList();
  // }

  // Future<List<Item>> getItems(String subCategory) async {
  //   final items = await _dao.getAllItems();
  //   return items.where((e) => e.itemSubCategory == subCategory).toList();
  // }

  // /// 🔹 NEW: get first item in subcategory for preview image
  // Future<Item?> getFirstItemBySubCategory(String subCategory) async {
  //   final items = await getItems(subCategory);
  //   return items.isNotEmpty ? items.first : null;
  // }
}
