import 'package:fixero/data/repositories/inventory/requested_item_repository.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';

class RequestedItemDAO {
  final RequestedItemRepository _repo = RequestedItemRepository();

  Future<List<RequestedItem>> getItemsByRequestID(String requestId) async {
    return await _repo.fetchItemsByRequestId(requestId);
  }

  Future<void> addRequestedItem(RequestedItem item) async {
    await _repo.addRequestedItem(item);
  }

  Future<void> updateRequestedItem(RequestedItem item) async {
    await _repo.updateRequestedItem(item);
  }

  Future<void> deleteRequestedItem(String requestItemId) async {
    await _repo.deleteRequestedItem(requestItemId);
  }

  Future<List<RequestedItem>> getRequestedItemsByItemID(String itemID) async {
    final all = await _repo.fetchAllRequestedItems();
    return all.where((r) => r.itemID == itemID).toList();
  }
}
