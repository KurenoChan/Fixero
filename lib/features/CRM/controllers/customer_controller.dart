import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/customer_model.dart';

class CustomerController extends ValueNotifier<int> {
  static final CustomerController _instance = CustomerController._internal();
  factory CustomerController() => _instance;

  CustomerController._internal() : super(0) {
    _init();
  }

  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref("users/customers");
  final Map<String, Customer> _byId = {};

  List<Customer> get allCustomers => _byId.values.toList(growable: false);

  Future<void> _init() async {
    final snap = await _dbRef.get();
    if (snap.exists) {
      for (final child in snap.children) {
        final id = child.key;
        if (id == null) continue;
        final data = Map<String, dynamic>.from(child.value as Map);
        final c = Customer.fromMap(id, data);
        _byId[id] = c;
      }
    }
    notifyListeners();
  }
  Future<void> updateCustomer(Customer customer) async {
    await _dbRef.child(customer.custID).update(customer.toMap());
    _byId[customer.custID] = customer; // ✅ update cache too
    notifyListeners();
  }



  /// 🔹 Fetch a customer by ID (used by Feedback Detail, Replies, etc.)
  Future<Customer?> fetchCustomerById(String customerId) async {
    // 1) Cached?
    if (_byId.containsKey(customerId)) {
      return _byId[customerId];
    }

    // 2) Fetch from Firebase
    final snap = await _dbRef.child(customerId).get();
    if (snap.exists) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      final c = Customer.fromMap(customerId, data);
      _byId[customerId] = c;
      return c;
    }

    return null;
  }
}
