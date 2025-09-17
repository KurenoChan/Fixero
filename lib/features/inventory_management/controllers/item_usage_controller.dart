import 'package:fixero/data/dao/inventory/item_usage_dao.dart';
import 'package:fixero/features/inventory_management/models/item_usage.dart';
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

  ItemUsage? getItemUsageById(String id) {
    try {
      return _itemUsages.firstWhere((item) => item.itemID == id);
    } catch (e) {
      return null;
    }
  }
}
