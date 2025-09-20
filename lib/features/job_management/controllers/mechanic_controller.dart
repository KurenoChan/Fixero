import 'package:flutter/foundation.dart';
import 'package:fixero/features/job_management/models/mechanic_model.dart';
import 'package:fixero/data/repositories/job_services/mechanic_repository.dart';

class MechanicController with ChangeNotifier {
  final MechanicRepository _mechanicRepository;
  List<Mechanic> _mechanics = [];
  bool _isLoading = false;
  String? _errorMessage;

  MechanicController(this._mechanicRepository);

  List<Mechanic> get mechanics => _mechanics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🔹 Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 🔹 Load all mechanics
  Future<void> loadMechanics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mechanics = await _mechanicRepository.fetchAllMechanics();
    } catch (e) {
      _errorMessage = 'Failed to load mechanics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Load only available mechanics
  Future<void> loadAvailableMechanics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mechanics = await _mechanicRepository.fetchAvailableMechanics();
    } catch (e) {
      _errorMessage = 'Failed to load available mechanics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Update mechanic status
  Future<void> updateMechanicStatus(String mechanicID, String status) async {
    try {
      await _mechanicRepository.updateMechanicStatus(mechanicID, status);

      // Update local state efficiently
      final index = _mechanics.indexWhere((m) => m.mechanicID == mechanicID);
      if (index != -1) {
        _mechanics[index] = _mechanics[index].copyWith(mechanicStatus: status);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update mechanic status: $e';
      notifyListeners();
    }
  }

  /// 🔹 Add a new mechanic
  Future<void> addMechanic(Mechanic mechanic) async {
    try {
      await _mechanicRepository.addMechanic(mechanic);
      await loadMechanics(); // Refresh the list
    } catch (e) {
      _errorMessage = 'Failed to add mechanic: $e';
      notifyListeners();
    }
  }

  /// 🔹 Delete a mechanic
  Future<void> deleteMechanic(String mechanicID) async {
    try {
      await _mechanicRepository.deleteMechanic(mechanicID);
      _mechanics.removeWhere((m) => m.mechanicID == mechanicID);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete mechanic: $e';
      notifyListeners();
    }
  }

  /// 🔹 Get available mechanics from current list
  List<Mechanic> getAvailableMechanics() {
    return _mechanics.where((mechanic) => mechanic.isAvailable).toList();
  }

  /// 🔹 Get mechanics by specialty
  List<Mechanic> getMechanicsBySpecialty(String specialty) {
    return _mechanics
        .where((mechanic) => mechanic.hasSpecialty(specialty))
        .toList();
  }

  /// 🔹 Get mechanic by ID
  Mechanic? getMechanicById(String mechanicID) {
    try {
      return _mechanics.firstWhere(
        (mechanic) => mechanic.mechanicID == mechanicID,
      );
    } catch (e) {
      return null;
    }
  }

  /// 🔹 Get mechanics by status
  List<Mechanic> getMechanicsByStatus(String status) {
    return _mechanics
        .where(
          (mechanic) =>
              mechanic.mechanicStatus.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  /// 🔹 Search mechanics by name
  List<Mechanic> searchMechanics(String query) {
    if (query.isEmpty) return _mechanics;

    return _mechanics
        .where(
          (mechanic) =>
              mechanic.mechanicName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              mechanic.mechanicEmail.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              mechanic.mechanicSpecialty.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
  }
}
