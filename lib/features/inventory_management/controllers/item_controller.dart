import 'package:fixero/data/dao/inventory/item_dao.dart';
import 'package:fixero/data/dao/inventory/order_dao.dart';
import 'package:fixero/data/dao/inventory/requested_item_dao.dart';
import 'package:fixero/data/dao/inventory/restock_request_dao.dart';
import 'package:fixero/data/dao/inventory/supplier_dao.dart';
import 'package:fixero/features/inventory_management/models/restock_record.dart';
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

  /// 🔹 Return all items (cached) for global search
  List<Item> getAllItemsSync() {
    return _items;
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
      _items.where((e) => e.stockQuantity > 0 && e.stockQuantity <= e.lowStockThreshold).toList();

  List<Item> get outOfStockItems =>
      _items.where((e) => e.stockQuantity == 0).toList();

  /// 🔹 Get item by ID
  Item? getItemByID(String id) {
    try {
      return _items.firstWhere((item) => item.itemID == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<RestockRecord>> getRestockingDetails(String itemID) async {
    final List<RestockRecord> details = [];
    final requestedItems = await RequestedItemDAO().getRequestedItemsByItemID(
      itemID,
    );

    for (final ri in requestedItems) {
      final rr = await RestockRequestDAO().getRestockRequestByID(ri.requestID);
      if (rr == null || rr.orderNo == null || rr.orderNo!.isEmpty) continue;

      final order = await OrderDAO().getOrderByID(rr.orderNo!);
      if (order == null || order.arrivalDate == null) continue;

      final supplier = await SupplierDAO().getSupplierByID(order.supplierID);
      if (supplier == null) continue;

      details.add(
        RestockRecord(
          requestedItem: ri,
          restockRequest: rr,
          order: order,
          supplier: supplier,
        ),
      );
    }

    return details;
  }

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

  /// 🔹 Delete item
  Future<void> deleteItem(String itemID) async {
    try {
      // 1️⃣ Find the item in the list
      final itemToDelete = _items.firstWhere(
        (i) => i.itemID == itemID,
        orElse: () => throw Exception("Item not found"),
      );

      // 2️⃣ Delete from Firebase via DAO
      await _dao.deleteItem(itemToDelete);

      // 3️⃣ Remove from local cache
      _items.remove(itemToDelete);

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
