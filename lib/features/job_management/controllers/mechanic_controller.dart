import 'package:flutter/foundation.dart';
import 'package:fixero/features/job_management/models/mechanic_model.dart';
import 'package:fixero/data/repositories/job_services/mechanic_repository.dart';

class MechanicController with ChangeNotifier {
  final MechanicRepository _mechanicRepository;

  List<Mechanic> _mechanics = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ✅ Optional constructor argument with default
  MechanicController([MechanicRepository? repository])
    : _mechanicRepository = repository ?? MechanicRepository();

  List<Mechanic> get mechanics => _mechanics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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

  Future<void> updateMechanicStatus(String mechanicID, String status) async {
    try {
      await _mechanicRepository.updateMechanicStatus(mechanicID, status);
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

  Future<void> addMechanic(Mechanic mechanic) async {
    try {
      await _mechanicRepository.addMechanic(mechanic);
      await loadMechanics();
    } catch (e) {
      _errorMessage = 'Failed to add mechanic: $e';
      notifyListeners();
    }
  }

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

  List<Mechanic> getAvailableMechanics() =>
      _mechanics.where((m) => m.isAvailable).toList();

  List<Mechanic> getMechanicsBySpecialty(String specialty) =>
      _mechanics.where((m) => m.hasSpecialty(specialty)).toList();

  Mechanic? getMechanicById(String mechanicID) {
    try {
      return _mechanics.firstWhere((m) => m.mechanicID == mechanicID);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadMechanicById(String mechanicID) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final mechanic = await _mechanicRepository.fetchMechanicById(mechanicID);
      if (mechanic != null &&
          !_mechanics.any((m) => m.mechanicID == mechanic.mechanicID)) {
        _mechanics.add(mechanic);
      }
    } catch (e) {
      _errorMessage = 'Failed to load mechanic: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Mechanic> getMechanicsByStatus(String status) => _mechanics
      .where((m) => m.mechanicStatus.toLowerCase() == status.toLowerCase())
      .toList();

  List<Mechanic> searchMechanics(String query) {
    if (query.isEmpty) return _mechanics;

    return _mechanics.where((m) {
      final q = query.toLowerCase();
      return m.mechanicName.toLowerCase().contains(q) ||
          m.mechanicEmail.toLowerCase().contains(q) ||
          m.mechanicSpecialty.toLowerCase().contains(q);
    }).toList();
  }
}
