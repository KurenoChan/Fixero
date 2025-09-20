import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get current user display name
  String? getCurrentUserName() {
    return _auth.currentUser?.displayName;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
