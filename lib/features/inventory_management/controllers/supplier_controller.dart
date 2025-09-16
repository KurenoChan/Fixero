import 'package:fixero/data/dao/inventory/supplier_dao.dart';
import 'package:flutter/foundation.dart';
import '../models/supplier.dart';

class SupplierController extends ChangeNotifier {
  final SupplierDAO _dao = SupplierDAO();

  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSuppliers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _suppliers = await _dao.getAllSuppliers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Supplier? getSupplierByIdSync(String id) {
    try {
      return _suppliers.firstWhere((s) => s.supplierID == id);
    } catch (_) {
      return null;
    }
  }
}
