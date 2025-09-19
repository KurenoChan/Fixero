import 'package:fixero/features/job_management/models/mechanic_model.dart';
import 'package:fixero/data/repositories/job_services/mechanic_repository.dart';

/*
********************************************************************************
OBJECTIVE: 
- Uses the repository to get raw mechanics.
- Does not care how we use the data — it only fetches or updates.
********************************************************************************
*/

class MechanicDAO {
  final MechanicRepository _repo = MechanicRepository();

  /// 🔹 Get all mechanics
  Future<List<Mechanic>> getAllMechanics() async {
    return await _repo.fetchAllMechanics();
  }

  /// 🔹 Get a specific mechanic by ID
  Future<Mechanic?> getMechanicById(String mechanicId) async {
    return await _repo.fetchMechanicById(mechanicId);
  }

  /// 🔹 Get available mechanics only
  Future<List<Mechanic>> getAvailableMechanics() async {
    return await _repo.fetchAvailableMechanics();
  }

  /// 🔹 Update mechanic status
  Future<void> updateMechanicStatus(String mechanicId, String newStatus) async {
    await _repo.updateMechanicStatus(mechanicId, newStatus);
  }

  /// 🔹 Update mechanic specialty
  Future<void> updateMechanicSpecialty(
    String mechanicId,
    String newSpecialty,
  ) async {
    await _repo.updateMechanicSpecialty(mechanicId, newSpecialty);
  }

  /// 🔹 Add a new mechanic
  Future<void> addMechanic(Mechanic mechanic) async {
    await _repo.addMechanic(mechanic);
  }

  /// 🔹 Delete a mechanic
  Future<void> deleteMechanic(String mechanicId) async {
    await _repo.deleteMechanic(mechanicId);
  }

  /// 🔹 Stream for real-time updates on all mechanics
  Stream<List<Mechanic>> watchMechanics() {
    return _repo.watchAllMechanics();
  }

  /// 🔹 Stream for real-time updates on a specific mechanic
  Stream<Mechanic?> watchMechanic(String mechanicId) {
    return _repo.watchMechanicById(mechanicId);
  }
}
