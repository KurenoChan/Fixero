import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/authentication/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/auth_service.dart';
import '../../../home_page.dart';

class AuthHandler {
  static Future<void> handleEmailAndPasswordLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // Waiting for authentication
      await AuthService.loginWithEmailAndPassword(email, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'This email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;
        default:
          debugPrint('Unknown login error: $e');
          message = 'Login failed. Please try again later.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
  static Future<void> handleForgotPassword(
      BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset email sent! Check your inbox."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).maybePop(); // back to login after sending
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case "invalid-email":
          message = "The email address is not valid.";
          break;
        case "user-not-found":
          message = "No user found with this email.";
          break;
        default:
          message = "Something went wrong. Please try again.";
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred. Try again later."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> handleEmailAndPasswordRegister(
    BuildContext context,
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      // Step 1: Create Auth user
      final userCredential = await AuthService.registerWithEmailAndPassword(
        email,
        password,
      );

      final uid = userCredential.user?.uid;

      if (uid != null) {
        final db = FirebaseDatabase.instance.ref("users/managers/$uid");

        await db.set({
          "managerName": username,
          "managerPassword": password,
          "managerEmail": email,
          "managerRole": "Workshop Manager",
          "profileImgUrl":
              "https://cdn-icons-png.flaticon.com/512/8847/8847419.png",
        });
      }

      // ✅ Use context safely after async
      if (!context.mounted) return;

      // Show the SnackBar first
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));

      // Optional: delay a tiny bit to let snackbar appear before navigating
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      final msg = e.code == 'email-already-in-use'
          ? 'Email already in use.'
          : 'Registration failed.';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  static Future<void> handleGoogleLogin(BuildContext context) async {
    try {
      final userCredential = await AuthService.loginWithGoogle();

      // If login failed or was cancelled
      if (userCredential == null || userCredential.user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Google login failed.")));
        }
        return;
      }

      if (!context.mounted) return;

      final user = userCredential.user!;
      final uid = user.uid;
      final dbRef = FirebaseDatabase.instance.ref("users/managers/$uid");

      // Check if this manager already exists in RTDB
      final snapshot = await dbRef.get();

      if (!snapshot.exists) {
        // If not found, insert new manager data
        await dbRef.set({
          "managerName": user.displayName ?? "Manager",
          "managerEmail": user.email ?? "",
          "managerPassword": "", // Google login → no password stored
          "managerRole": "Workshop Manager",
          "profileImgUrl":
              user.photoURL ??
              "https://cdn-icons-png.flaticon.com/512/8847/8847419.png",
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  static Future<void> handleSignOut(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  /// 🔹 Added: Forgot Password handler (does NOT change your existing code)
  static Future<void> handlePasswordReset(
    BuildContext context,
    String email,
  ) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email address.')),
        );
      }
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmed);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset link sent! Check your inbox.')),
        );
        Navigator.of(context).maybePop();
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for that email.';
          break;
        case 'invalid-email':
          message = 'That email address is invalid.';
          break;
        case 'missing-email':
          message = 'Please enter your email address.';
          break;
        default:
          message =
              e.message ?? 'Could not send reset email. Please try again.';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }
}
