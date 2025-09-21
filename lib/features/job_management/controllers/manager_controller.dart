import 'package:flutter/foundation.dart';
import 'package:fixero/features/job_management/models/manager_model.dart';
import 'package:fixero/data/services/manager_service.dart';

class ManagerController with ChangeNotifier {
  final ManagerService _managerService;

  List<Manager> _managers = [];
  bool _isLoading = false;
  String? _errorMessage;

  ManagerController([ManagerService? service])
    : _managerService = service ?? ManagerService();

  // 🔹 Getters
  List<Manager> get managers => _managers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 🔹 Load all managers
  Future<void> loadManagers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _managers = await _managerService.getAllManagers();
    } catch (e) {
      _errorMessage = 'Failed to load managers: $e';
      _managers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Load manager by ID (always updates or adds in cache)
  Future<void> loadManagerById(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final manager = await _managerService.getManagerById(uid);
      if (manager != null) {
        final index = _managers.indexWhere((m) => m.uid == manager.uid);
        if (index != -1) {
          _managers[index] = manager; // update existing
        } else {
          _managers.add(manager); // add new
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load manager: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Get manager by ID (from memory cache safely)
  Manager? getManagerById(String uid) {
    return _managers.where((m) => m.uid == uid).cast<Manager?>().firstOrNull;
  }

  /// 🔹 Add new manager
  Future<void> addManager(Manager manager) async {
    try {
      await _managerService.createManager(manager);
      await loadManagers(); // refresh cache
    } catch (e) {
      _errorMessage = 'Failed to add manager: $e';
      notifyListeners();
    }
  }

  /// 🔹 Update manager
  Future<void> updateManager(
    String uid,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final updated = await _managerService.updateManager(uid, updateData);
      if (updated != null) {
        final index = _managers.indexWhere((m) => m.uid == uid);
        if (index != -1) {
          _managers[index] = updated;
        } else {
          _managers.add(updated);
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update manager: $e';
      notifyListeners();
    }
  }

  /// 🔹 Delete manager
  Future<void> deleteManager(String uid) async {
    try {
      await _managerService.deleteManager(uid);
      _managers.removeWhere((m) => m.uid == uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete manager: $e';
      notifyListeners();
    }
  }

  /// 🔹 Search managers (case-insensitive, local cache)
  List<Manager> searchManagers(String query) {
    if (query.isEmpty) return _managers;

    final q = query.toLowerCase();
    return _managers.where((m) {
      return m.managerName.toLowerCase().contains(q) ||
          m.managerEmail.toLowerCase().contains(q) ||
          m.managerRole.toLowerCase().contains(q);
    }).toList();
  }

  /// 🔹 Get managers by role (local cache)
  List<Manager> getManagersByRoleCached(String role) => _managers
      .where((m) => m.managerRole.toLowerCase() == role.toLowerCase())
      .toList();
}
