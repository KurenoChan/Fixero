import 'package:firebase_database/firebase_database.dart';
import '../../../features/inventory_management/models/supplier.dart';

class SupplierRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref('inventory/suppliers');

  Future<List<Supplier>> fetchAllSuppliers() async {
    final snapshot = await _db.get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

    return data.entries
        .map((entry) => Supplier.fromMap(entry.value, entry.key))
        .toList();
  }
}
