import 'package:fixero/data/repositories/inventory/restock_request_repository.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';

class RestockRequestDAO {
  final RestockRequestRepository _repo = RestockRequestRepository();

  Future<List<RestockRequest>> getAllRequests() async {
    return await _repo.fetchAllRequests();
  }

  Future<void> createRequest(RestockRequest request) async {
    await _repo.addRequest(request);
  }

  Future<void> updateRequest(RestockRequest request) async {
    await _repo.updateRequest(request);
  }

  Future<void> deleteRequest(String requestId) async {
    await _repo.deleteRequest(requestId);
  }

  /// Convenience filters
  Future<List<RestockRequest>> getPendingRequests() async {
    final all = await _repo.fetchAllRequests();
    return all.where((r) => r.status == "Pending").toList();
  }

  Future<List<RestockRequest>> getApprovedRequests() async {
    final all = await _repo.fetchAllRequests();
    return all.where((r) => r.status == "Approved").toList();
  }

  Future<List<RestockRequest>> getRequestsByOrderNo(String orderNo) async {
    final allRequests = await _repo.fetchAllRequests();
    return allRequests.where((r) => r.orderNo == orderNo).toList();
  }
}
