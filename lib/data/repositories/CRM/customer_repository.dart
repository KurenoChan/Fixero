import 'package:firebase_database/firebase_database.dart';
import '../../../features/CRM/models/customer_model.dart';

class CustomerRepository {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref("users/customers");

  Future<List<Customer>> fetchAllCustomers() async {
    final snap = await _dbRef.get();
    if (!snap.exists) return [];

    return snap.children.map((child) {
      final id = child.key!;
      final data = Map<String, dynamic>.from(child.value as Map);
      return Customer.fromMap(id, data);
    }).toList();
  }

  Future<Customer?> fetchCustomerById(String id) async {
    final snap = await _dbRef.child(id).get();
    if (!snap.exists) return null;

    return Customer.fromMap(
      id,
      Map<String, dynamic>.from(snap.value as Map),
    );
  }

  Future<void> addCustomer(Customer customer) async {
    await _dbRef.child(customer.custID).set(customer.toMap());
  }

  Future<void> updateCustomer(Customer customer) async {
    await _dbRef.child(customer.custID).update(customer.toMap());
  }

  Future<void> deleteCustomer(String id) async {
    await _dbRef.child(id).remove();
  }
}
