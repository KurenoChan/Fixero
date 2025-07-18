import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    await AuthService.signOut();

    // Use a post-frame callback to safely navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Home Page"),
            IconButton(
              onPressed: () => _handleSignOut(context), // 👈 pass context here
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
