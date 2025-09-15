import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/requesteditem_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restockrequest_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/styles/dark_mode.dart';
import 'common/styles/light_mode.dart';
import 'features/authentication/views/login_page.dart';
import 'features/intro/views/intro_page.dart';
import 'features/inventory_management/views/inventory_page.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ************************
  // TODO: REMOVE THIS LATER
  // ************************
  // Force logout for testing
  // await FirebaseAuth.instance.signOut();

  // Read intro flag once
  final prefs = await SharedPreferences.getInstance();
  final seenIntro = prefs.getBool('seenIntro') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryController()),
        ChangeNotifierProvider(create: (_) => RequestedItemController()),
        ChangeNotifierProvider(create: (_) => RestockRequestController()),
      ],
      child: MainApp(seenIntro: seenIntro),
    ),
  );
}

class MainApp extends StatelessWidget {
  final bool seenIntro;
  const MainApp({super.key, required this.seenIntro});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: ThemeMode.system,
      // initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (_) => const HomePage(),
        InventoryPage.routeName: (_) => const InventoryPage(),
      },

      home: AnimatedSplashScreen(
        splash: 'assets/logo/splash_fixero.gif',
        splashIconSize: 2000.0,
        centered: true,
        nextScreen: AuthGate(seenIntro: seenIntro),
        backgroundColor: Colors.black,
        duration: 4000,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final bool seenIntro;
  const AuthGate({super.key, required this.seenIntro});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!seenIntro) return const IntroPage();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
