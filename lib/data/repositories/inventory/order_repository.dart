import 'package:firebase_database/firebase_database.dart';
import '../../../features/inventory_management/models/order.dart';

class OrderRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(
    "inventory/orders",
  );

  Future<List<Order>> fetchAllOrders() async {
    final snapshot = await _db.get();
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((e) => Order.fromMap(e.value, e.key)).toList();
  }

  Future<void> addOrder(Order order) async {
    await _db.child(order.orderNo).set(order.toMap());
  }

  Future<void> updateOrder(String orderNo, Order updatedOrder) async {
    await _db.child(orderNo).update(updatedOrder.toMap());
  }

  Future<void> deleteOrder(String orderNo) async {
    await _db.child(orderNo).remove();
  }
}
