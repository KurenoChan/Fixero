// controllers/customer_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/customer_model.dart';

class CustomerController extends ValueNotifier<int> {
  static final CustomerController _instance = CustomerController._internal();
  factory CustomerController() => _instance;

  CustomerController._internal() : super(0) {
    _init();
  }

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("users/customers");
  final Map<String, Customer> _byId = {};
  StreamSubscription? _subAdded;
  StreamSubscription? _subChanged;
  StreamSubscription? _subRemoved;

  List<Customer> get allCustomers => _byId.values.toList(growable: false);

  Future<void> _init() async {
    // Initial load
    final snap = await dbRef.get();
    if (snap.exists) {
      for (final child in snap.children) {
        final id = child.key!;
        final data = Map<String, dynamic>.from(child.value as Map);
        _byId[id] = Customer.fromMap(id, data);
      }
    }
    _notify();

    // Sync listeners
    _subAdded = dbRef.onChildAdded.listen((event) {
      final id = event.snapshot.key!;
      if (_byId.containsKey(id)) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _byId[id] = Customer.fromMap(id, data);
      _notify();
    });

    _subChanged = dbRef.onChildChanged.listen((event) {
      final id = event.snapshot.key!;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _byId[id] = Customer.fromMap(id, data);
      _notify();
    });

    _subRemoved = dbRef.onChildRemoved.listen((event) {
      final id = event.snapshot.key!;
      _byId.remove(id);
      _notify();
    });
  }

  void _notify() => value = _byId.length;

  Customer? getById(String id) => _byId[id];

  Future<void> updateCustomer(Customer c) async {
    _byId[c.custID] = c;
    _notify();
    await dbRef.child(c.custID).update(c.toMap());
  }

  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    super.dispose();
  }
}
