import 'package:flutter/foundation.dart';
import 'package:fixero/data/dao/inventory/order_dao.dart';
import '../models/order.dart';

class OrderController extends ChangeNotifier {
  final OrderDAO _dao = OrderDAO();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _dao.getAllOrders();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrder(Order order) async {
    try {
      await _dao.addOrder(order);
      _orders.add(order);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      await _dao.updateOrder(order);
      final index = _orders.indexWhere((o) => o.orderNo == order.orderNo);
      if (index != -1) _orders[index] = order;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderNo) async {
    try {
      await _dao.deleteOrder(orderNo);
      _orders.removeWhere((o) => o.orderNo == orderNo);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<Order> getOrdersBySupplier(String supplierID) =>
      _orders.where((o) => o.supplierID == supplierID).toList();
}
