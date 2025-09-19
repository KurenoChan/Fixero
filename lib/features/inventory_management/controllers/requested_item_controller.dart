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
      _items = await _dao.getItemsByRequestID(requestId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Add new requested item
  Future<void> addRequestedItem(RequestedItem item) async {
    try {
      await _dao.addRequestedItem(item);
      _items.add(item);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 🔹 Update requested item
  Future<void> updateRequestedItem(RequestedItem item) async {
    try {
      await _dao.updateRequestedItem(item);

      final index = _items.indexWhere(
        (i) => i.requestItemID == item.requestItemID,
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
  Future<void> deleteRequestedItem(String requestItemID) async {
    try {
      await _dao.deleteRequestedItem(requestItemID);
      _items.removeWhere((i) => i.requestItemID == requestItemID);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 🔹 Batch update status for all items of a request
  // Future<void> updateRequestedItemsStatusByRequestId(
  //   String requestId,
  //   String status,
  // ) async {
  //   final items = await _dao.getItemsByRequestId(requestId);

  //   for (var item in items) {
  //     final updated = item.copyWith(status: status);
  //     await _dao.updateRequestedItem(updated);
  //   }

  //   // If you’re storing `_items` for the current request, refresh it
  //   _items = await _dao.getItemsByRequestId(requestId);
  //   notifyListeners();
  // }
  Future<void> updateRequestedItemsStatusByRequestId(
    String requestId,
    String status,
  ) async {
    // Filter cached items for the request
    final itemsToUpdate = _items
        .where((i) => i.requestID == requestId)
        .toList();

    for (var item in itemsToUpdate) {
      final updated = item.copyWith(status: status);
      await _dao.updateRequestedItem(updated);

      // Update cache
      final index = _items.indexWhere(
        (i) => i.requestItemID == item.requestItemID,
      );
      if (index != -1) _items[index] = updated;
    }

    notifyListeners();
  }

  /// 🔹 Get pending items for a specific request
  List<RequestedItem> getPendingItems(String requestId) {
    return _items
        .where((i) => i.requestID == requestId && i.status == "Pending")
        .toList();
  }

  /// 🔹 Get received items for a specific request
  List<RequestedItem> getReceivedItems(String requestId) {
    return _items
        .where((i) => i.requestID == requestId && i.status == "Received")
        .toList();
  }

  /// 🔹 Helpers
  List<RequestedItem> get pendingItems =>
      _items.where((i) => i.status == "Pending").toList();

  List<RequestedItem> get receivedItems =>
      _items.where((i) => i.status == "Received").toList();

  List<RequestedItem> getItemsByRequestIdSync(String requestId) =>
      _items.where((i) => i.requestID == requestId).toList();
}
