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

  Future<Order?> getOrderByID(String orderNo) async {
    final all = await _repo.fetchAllOrders();
    try {
      return all.firstWhere((o) => o.orderNo == orderNo);
    } catch (_) {
      return null;
    }
  }
}
