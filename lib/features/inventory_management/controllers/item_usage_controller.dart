import 'package:fixero/data/dao/inventory/item_usage_dao.dart';
import 'package:fixero/features/inventory_management/models/item_usage.dart';
import 'package:fixero/features/inventory_management/models/usage_details.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:flutter/material.dart';

class ItemUsageController extends ChangeNotifier {
  final ItemUsageDAO _dao = ItemUsageDAO();

  List<ItemUsage> _itemUsages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ItemUsage> get itemUsages => _itemUsages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all item usages from Firebase once
  Future<void> loadItemUsages() async {
    _isLoading = true;
    notifyListeners();

    try {
      _itemUsages = await _dao.getAllItemUsages();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ItemUsage> getItemUsagesByItemID(String id) {
    return itemUsages.where((u) => u.itemID == id).toList();
  }

  ItemUsage? getItemUsageById(String id) {
    try {
      return _itemUsages.firstWhere((item) => item.itemID == id);
    } catch (e) {
      return null;
    }
  }

  List<UsageDetails> getUsageDetailsForItem(String itemID, List<Job> jobs) {
    final usages = getItemUsagesByItemID(itemID);
    debugPrint("ItemID=$itemID, usages=${usages.length}, jobs=${jobs.length}");

    return usages.map((usage) {
      final job = jobs.cast<Job?>().firstWhere(
        (j) => j?.jobID == usage.jobID,
        orElse: () => null,
      );

      debugPrint("usage.jobID=${usage.jobID}, foundJob=${job?.jobServiceType}");

      return UsageDetails(
        service: job?.jobServiceType ?? "Unknown",
        usageDate: usage.usageDate,
        usageTime: usage.usageTime,
        quantity: usage.quantityUsed ?? 0,
      );
    }).toList();
  }
}
