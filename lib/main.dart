import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:fixero/pages/intro/intro_page.dart';
import 'package:fixero/pages/main/home_page.dart';
import 'package:fixero/pages/main/login_page.dart';
import 'package:fixero/theme/dark_mode.dart';
import 'package:fixero/theme/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'firebase_options.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign-In
  await GoogleSignIn.instance.initialize();

  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();
  final seenIntro = prefs.getBool('seenIntro') ?? false;
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MainApp(seenIntro: seenIntro, isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool seenIntro;
  final bool isLoggedIn;

  const MainApp({super.key, required this.seenIntro, required this.isLoggedIn});

  Widget _getNextScreen() {
    if (!seenIntro) {
      return const IntroPage();
    } else if (!isLoggedIn) {
      return const LoginPage();
    } else {
      return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: lightMode,
      darkTheme: darkMode,
      themeMode: ThemeMode.system,

      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.black,
      //     brightness: Brightness.dark, // Important to switch to dark mode
      //   ),
      //   // Background color for all pages
      //   scaffoldBackgroundColor: Colors.black,
      //   textTheme: const TextTheme(
      //     bodyLarge: TextStyle(color: Colors.white),
      //     bodyMedium: TextStyle(color: Colors.white),
      //     titleLarge: TextStyle(color: Colors.white),
      //   ),
      //   appBarTheme: const AppBarTheme(
      //     backgroundColor: Colors.black,
      //     foregroundColor: Colors.white, // For title/icon color in AppBar
      //   ),
      //
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Colors.white,
      //       foregroundColor: Colors.black,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(10),
      //       ),
      //     ),
      //   ),
      //
      //   inputDecorationTheme: const InputDecorationTheme(
      //     filled: true,
      //     fillColor: Colors.white10,
      //     labelStyle: TextStyle(color: Colors.white),
      //     hintStyle: TextStyle(color: Colors.grey),
      //     border: OutlineInputBorder(
      //       borderSide: BorderSide(color: Colors.white),
      //     ),
      //     enabledBorder: OutlineInputBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(5)),
      //       borderSide: BorderSide(color: Colors.white),
      //     ),
      //     focusedBorder: OutlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue),
      //     ),
      //   ),
      // ),

      home: AnimatedSplashScreen(
        splash: 'assets/images/logo/splash_fixero.gif',
        splashIconSize: 2000.0,
        centered: true,
        nextScreen: _getNextScreen(),
        backgroundColor: Colors.black,
        duration: 4000,
      ),
    );
  }
}
