import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/features/authentication/models/manager.dart';

class ManagerController {

  /// Get the currently logged in Manager profile from Firestore
  static Future<Manager?> getCurrentManager() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;

    return await ManagerRepository().getManager(firebaseUser.uid);
  }
}
