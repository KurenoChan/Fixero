import 'package:fixero/data/dao/manager_service/manager_dao.dart';
import 'package:fixero/features/job_management/models/manager_model.dart';

class ManagerRepository {
  final ManagerDAO _managerDAO = ManagerDAO();

  Future<Manager> createManager(
    String uid,
    Map<String, dynamic> managerData,
  ) async {
    final manager = Manager(
      uid: uid,
      managerName: managerData['managerName'] ?? '',
      managerEmail: managerData['managerEmail'] ?? '',
      managerRole: managerData['managerRole'] ?? '',
      profileImgUrl: managerData['profileImgUrl'],
    );

    return await _managerDAO.create(manager);
  }

  Future<Manager?> getManagerById(String uid) async {
    return await _managerDAO.getById(uid);
  }

  Future<List<Manager>> getAllManagers() async {
    return await _managerDAO.getAll();
  }

  Future<Manager> updateManager(
    String uid,
    Map<String, dynamic> updateData,
  ) async {
    return await _managerDAO.update(uid, updateData);
  }

  Future<bool> deleteManager(String uid) async {
    return await _managerDAO.delete(uid);
  }

  Future<List<Manager>> getManagersByRole(String role) async {
    return await _managerDAO.getByRole(role);
  }

  Future<Manager?> getManagerByEmail(String email) async {
    return await _managerDAO.getByEmail(email);
  }

  Future<List<Manager>> getWorkshopManagers() async {
    return await getManagersByRole('Workshop Manager');
  }

  Future<List<Manager>> getInventoryManagers() async {
    return await getManagersByRole('Inventory Manager');
  }

  Stream<List<Manager>> streamAllManagers() {
    return _managerDAO.streamAll();
  }

  Stream<Manager?> streamManagerById(String uid) {
    return _managerDAO.streamById(uid);
  }
}
