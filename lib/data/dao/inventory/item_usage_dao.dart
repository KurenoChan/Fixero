/*
********************************************************************************
OBJECTIVE: 
- Uses the repository to get raw item usages.
- Does not care how we use the data — it only fetches or updates.
********************************************************************************
*/

import 'package:fixero/data/repositories/inventory/item_usage_repository.dart';
import 'package:fixero/features/inventory_management/models/item_usage.dart';

class ItemUsageDAO {
  final ItemUsageRepository _repo = ItemUsageRepository();

  Future<List<ItemUsage>> getAllItemUsages() async {
    return await _repo.fetchAllItemUsages();
  }

  Future<List<ItemUsage>> getItemUsagesByItemID(String itemID) async {
    final all = await getAllItemUsages();
    return all.where((u) => u.itemID == itemID).toList();
  }

  Future<void> addItemUsage(ItemUsage itemUsage) async {
    await _repo.addItemUsage(itemUsage);
  }

  Future<void> updateItemUsage(ItemUsage itemUsage) async {
    await _repo.updateItemUsage(itemUsage.itemUsageNo, itemUsage);
  }

  Future<void> deleteItemUsage(String itemUsageNo) async {
    await _repo.deleteItemUsage(itemUsageNo);
  }
}
