import 'package:fixero/data/dao/inventory/requested_item_dao.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:flutter/foundation.dart';

class RequestedItemController extends ChangeNotifier {
  final RequestedItemDAO _dao = RequestedItemDAO();

  List<RequestedItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RequestedItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🔹 Load items for a specific request
  Future<void> loadItemsByRequestId(String requestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _dao.getItemsByRequestId(requestId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Add new requested item
  Future<void> createItem(RequestedItem item) async {
    try {
      await _dao.createItem(item);
      _items.add(item);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 🔹 Update requested item
  Future<void> updateItem(RequestedItem item) async {
    try {
      await _dao.updateItem(item);

      final index = _items.indexWhere(
        (i) => i.requestItemId == item.requestItemId,
      );
      if (index != -1) {
        _items[index] = item;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 🔹 Delete requested item
  Future<void> deleteItem(String requestItemId) async {
    try {
      await _dao.deleteItem(requestItemId);
      _items.removeWhere((i) => i.requestItemId == requestItemId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateItemsStatusByRequestId(
    String requestId,
    String status,
  ) async {
    final items = await _dao.getItemsByRequestId(requestId);

    for (var item in items) {
      final updated = item.copyWith(status: status);
      await _dao.updateItem(updated);
    }

    // If you’re storing `_items` for the current request, refresh it
    _items = await _dao.getItemsByRequestId(requestId);
    notifyListeners();
  }

  /// 🔹 Helpers
  List<RequestedItem> get pendingItems =>
      _items.where((i) => i.status == "Pending").toList();

  List<RequestedItem> get receivedItems =>
      _items.where((i) => i.status == "Received").toList();
}
