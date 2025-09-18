import 'package:fixero/data/repositories/inventory/restock_request_repository.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';

class RestockRequestDAO {
  final RestockRequestRepository _repo = RestockRequestRepository();

  Future<List<RestockRequest>> getAllRequests() async {
    return await _repo.fetchAllRequests();
  }

  Future<void> addRequest(RestockRequest request) async {
    await _repo.addRequest(request);
  }

  Future<void> updateRequest(RestockRequest request) async {
    await _repo.updateRequest(request);
  }

  Future<void> deleteRequest(String requestID) async {
    await _repo.deleteRequest(requestID);
  }

  Future<RestockRequest?> getRestockRequestByID(String requestID) async {
    final all = await _repo.fetchAllRequests();
    try {
      return all.firstWhere((r) => r.requestID == requestID);
    } catch (_) {
      return null;
    }
  }
}
