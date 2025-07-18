import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  // ====================
  // Authentication
  // ====================
  // 1. Email-Password
  // 1.1 LOGIN
  static Future<UserCredential> loginWithEmailAndPassword(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }
  // 1.2 REGISTRATION
  static Future<UserCredential> registerWithEmailAndPassword(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // 2. Google Account
  // 2.1 LOGIN
  static Future<UserCredential?> loginWithGoogle() async {
    try {
      // Initialize GoogleSignIn
      await GoogleSignIn.instance.initialize(
        serverClientId: '432176160698-k6j2uft5t7dgnfqcs8ssfk2nu3gs1uqq.apps.googleusercontent.com',
      );

      // Start Google Login
      final googleUser = await GoogleSignIn.instance.authenticate();

      final googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception("Missing ID token.");
      }

      // Convert Google credential to Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Login to Firebase with Google credential
      final result = await _auth.signInWithCredential(credential);

      // Set logged-in flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return result;
    } on GoogleSignInException catch (e) {
      // Google login failed
      String message;

      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          message = 'Login was canceled by the user.';
          break;
        case GoogleSignInExceptionCode.interrupted:
          message = 'Login was interrupted. Please try again.';
          break;
        case GoogleSignInExceptionCode.uiUnavailable:
          message = 'Google login UI is unavailable.';
          break;
        default:
          print('Unknown Google login error: $e');
          message = 'Google login failed. Please try again.';
      }

      throw Exception(message); // Or return null with custom error handling

    } on FirebaseAuthException catch (e) {
      // Firebase-related error
      String message = 'Authentication failed. Please try again.';

      if (e.code == 'account-exists-with-different-credential') {
        message = 'This email is already registered using a different method.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid credential received. Please try again.';
      }

      throw Exception(message);

    } catch (e) {
      // Generic fallback
      const message = 'An unexpected error occurred. Please try again.';
      throw Exception(message);
    }
  }

  // 3. LOGOUT
  static Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  static User? get currentUser => _auth.currentUser;
}