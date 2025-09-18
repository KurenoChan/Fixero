// customer_controller.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/customer_model.dart';

class CustomerController {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref().child("users/customers");

  Future<Customer?> fetchCustomer(String customerId) async {
    final snap = await _dbRef.child(customerId).get();
    if (!snap.exists) return null;

    return Customer.fromMap(
        Map<String, dynamic>.from(snap.value as Map), snap.key!);
  }
}
