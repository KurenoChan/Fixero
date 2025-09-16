import 'package:fixero/data/repositories/inventory/requested_item_repository.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';

class RequestedItemDAO {
  final RequestedItemRepository _repo = RequestedItemRepository();

  Future<List<RequestedItem>> getItemsByRequestId(String requestId) async {
    return await _repo.fetchItemsByRequestId(requestId);
  }

  Future<void> createItem(RequestedItem item) async {
    await _repo.addItem(item);
  }

  Future<void> updateItem(RequestedItem item) async {
    await _repo.updateItem(item);
  }

  Future<void> deleteItem(String requestItemId) async {
    await _repo.deleteItem(requestItemId);
  }

  /// Convenience filters
  Future<List<RequestedItem>> getPendingItems(String requestId) async {
    final all = await _repo.fetchItemsByRequestId(requestId);
    return all.where((i) => i.status == "Pending").toList();
  }

  Future<List<RequestedItem>> getReceivedItems(String requestId) async {
    final all = await _repo.fetchItemsByRequestId(requestId);
    return all.where((i) => i.status == "Received").toList();
  }
}