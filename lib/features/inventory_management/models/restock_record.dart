import 'package:fixero/features/inventory_management/models/order.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';
import 'package:fixero/features/inventory_management/models/supplier.dart';

class RestockRecord {
  final Supplier supplier;
  final Order order;
  final RequestedItem requestedItem;
  final RestockRequest restockRequest;

  RestockRecord({
    required this.supplier,
    required this.order,
    required this.requestedItem,
    required this.restockRequest,
  });

  RestockRecord copyWith({
    Supplier? supplier,
    Order? order,
    RequestedItem? requestedItem,
    RestockRequest? restockRequest,
  }) {
    return RestockRecord(
      supplier: supplier ?? this.supplier,
      order: order ?? this.order,
      requestedItem: requestedItem ?? this.requestedItem,
      restockRequest: restockRequest ?? this.restockRequest,
    );
  }

  
}
