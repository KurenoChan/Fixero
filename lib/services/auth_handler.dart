import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixero/pages/main/home_page.dart';
import 'package:fixero/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/main/login_page.dart';

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
      String message = switch (e.code) {
        'user-not-found' => 'No user found.',
        'wrong-password' => 'Wrong password.',
        _ => 'Login failed. Please try again.',
      };

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  static Future<void> handleEmailAndPasswordRegister(
    BuildContext context,
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      await AuthService.registerWithEmailAndPassword(email, password);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'email-already-in-use'
          ? 'Email already in use.'
          : 'Registration failed.';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  static Future<void> handleGoogleLogin(BuildContext context) async {
    try {
      await AuthService.loginWithGoogle();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
