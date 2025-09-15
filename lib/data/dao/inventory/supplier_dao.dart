import '../../repositories/inventory/supplier_repository.dart';
import '../../../features/inventory_management/models/supplier.dart';

class SupplierDAO {
  final SupplierRepository _repo = SupplierRepository();

  Future<List<Supplier>> getAllSuppliers() async {
    return await _repo.fetchAllSuppliers();
  }

  Future<Supplier?> getSupplierById(String supplierID) async {
    final suppliers = await _repo.fetchAllSuppliers();
    try {
      return suppliers.firstWhere((s) => s.supplierID == supplierID);
    } catch (_) {
      return null;
    }
  }
}
