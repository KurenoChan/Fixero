import '../../../features/inventory_management/models/order.dart';
import '../../repositories/inventory/order_repository.dart';

class OrderDAO {
  final OrderRepository _repo = OrderRepository();

  Future<List<Order>> getAllOrders() async => await _repo.fetchAllOrders();

  Future<void> addOrder(Order order) async => await _repo.addOrder(order);

  Future<void> updateOrder(Order order) async =>
      await _repo.updateOrder(order.orderNo, order);

  Future<void> deleteOrder(String orderNo) async =>
      await _repo.deleteOrder(orderNo);

  // Future<List<Order>> getOrdersBySupplier(String supplierID) async {
  //   final orders = await _repo.fetchAllOrders();
  //   return orders.where((o) => o.supplierID == supplierID).toList();
  // }
}
