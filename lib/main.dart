import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixero/features/crm/views/customer_relationship_page.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/item_usage_controller.dart';
import 'package:fixero/features/inventory_management/controllers/order_controller.dart';
import 'package:fixero/features/inventory_management/controllers/requested_item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restock_request_controller.dart';
import 'package:fixero/features/inventory_management/controllers/supplier_controller.dart';
import 'package:fixero/features/job_management/controllers/add_job_controller.dart';
import 'package:fixero/features/job_management/controllers/job_controller.dart';
import 'package:fixero/features/job_management/views/jobs_page.dart';
import 'package:fixero/features/vehicle_management/views/car_models_view.dart';
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

  // Read intro flag once
  final prefs = await SharedPreferences.getInstance();
  final seenIntro = prefs.getBool('seenIntro') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemController()),
        ChangeNotifierProvider(create: (_) => RequestedItemController()),
        ChangeNotifierProvider(create: (_) => RestockRequestController()),
        ChangeNotifierProvider(create: (_) => SupplierController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => ItemUsageController()),

        ChangeNotifierProvider(create: (_) => JobController()),
        ChangeNotifierProvider(create: (_) => AddJobController()),
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
      routes: {
        HomePage.routeName: (_) => const HomePage(),
        JobsPage.routeName: (_) => const JobsPage(),
        CarModelsView.routeName: (_) => const CarModelsView(),
        InventoryPage.routeName: (_) => const InventoryPage(),
        CrmHomePage.routeName: (_) => const CrmHomePage(),
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
