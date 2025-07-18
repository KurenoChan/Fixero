import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class HomePage extends StatelessWidget {

  const HomePage({super.key});

  Future<void> _handleSignOut() async {
    await AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Home Page"),

            IconButton(onPressed: _handleSignOut, icon: Icon(Icons.logout),),
          ],
        ),
      ),
    );
  }
}
