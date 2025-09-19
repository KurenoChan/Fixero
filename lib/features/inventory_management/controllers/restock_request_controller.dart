import 'package:fixero/data/dao/inventory/restock_request_dao.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/foundation.dart';

class RestockRequestController extends ChangeNotifier {
  final RestockRequestDAO _dao = RestockRequestDAO();

  List<RestockRequest> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RestockRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🔹 Load all requests from Firebase once
  Future<void> loadRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      _requests = await _dao.getAllRequests();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔹 Add new request
  Future<void> addRequest(RestockRequest request) async {
    try {
      await _dao.addRequest(request);
      _requests.add(request);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 🔹 Update request (approve/reject)
  Future<void> updateRequest(RestockRequest request) async {
    try {
      await _dao.updateRequest(request);

      final index = _requests.indexWhere(
        (r) => r.requestID == request.requestID,
      );
      if (index != -1) {
        _requests[index] = request;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Approve / reject helpers
  Future<void> approveRequest(RestockRequest request, String managerId) =>
      _updateStatus(request, "Approved", managerId);

  Future<void> rejectRequest(RestockRequest request, String managerId) =>
      _updateStatus(request, "Rejected", managerId);

  Future<void> _updateStatus(
    RestockRequest request,
    String status,
    String managerId,
  ) async {
    try {
      final updated = status == "Approved"
          ? request.copyWith(
              status: status,
              approvedBy: managerId,
              approvedDate: Formatter.todayDate(),
            )
          : request.copyWith(
              status: status,
              rejectedBy: managerId,
              rejectedDate: Formatter.todayDate(),
            );

      await _dao.updateRequest(updated);

      final index = _requests.indexWhere(
        (r) => r.requestID == updated.requestID,
      );
      if (index != -1) _requests[index] = updated;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<RestockRequest> getRequestsByOrderNo(String orderNo) =>
      _requests.where((r) => r.orderNo == orderNo).toList();

  /// 🔹 Filter helpers
  List<RestockRequest> get pendingRequests =>
      _requests.where((r) => r.status == "Pending").toList();

  List<RestockRequest> get approvedRequests =>
      _requests.where((r) => r.status == "Approved").toList();
}
