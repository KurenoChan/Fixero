import 'package:fixero/components/fixero_homeappbar.dart';
import 'package:flutter/material.dart';

// import '../../services/auth_service.dart';
// import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Future<void> _handleSignOut(BuildContext context) async {
  //   await AuthService.signOut();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Navigator.of(context).pushAndRemoveUntil(
  //       MaterialPageRoute(builder: (context) => const LoginPage()),
  //       (route) => false,
  //     );
  //   });
  // }

  void _handleServiceTap(BuildContext context, String label, IconData icon) {
    // Example behavior: show a dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 10),
            Text("You tapped on $label"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: const FixeroHomeAppbar(
          username: "Henry Roosevelt",
          profileImgUrl: "https://i.pravatar.cc/150?img=11",
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const SizedBox(height: 10),

            // =====================
            // 1. Dashboard Overview
            // =====================

            // Dashboard Rows
            _buildDashboardRow(context, [
              _dashboardCard(context, "Active Jobs", "10"),
              _dashboardCard(context, "Low Stock Part", "Brake Pads"),
            ]),
            const SizedBox(height: 20),
            _buildDashboardRow(context, [
              _dashboardCard(context, "Invoices", "5"),
              _dashboardCard(context, "Appointments", "3"),
            ]),

            const SizedBox(height: 40),

            // ======================
            // 2. Recommended Section
            // ======================
            Column(
              spacing: 10.0,
              children: [
                // Section Title + See All Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recommended", style: TextStyle(fontSize: 17)),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: theme.colorScheme.inversePrimary
                            .withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Service Cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 10.0,
                          children: [
                            _recommendedServiceCard(context, "Oil Change", Icons.oil_barrel),
                            _recommendedServiceCard(context, "Tire Rotation", Icons.sync),
                            _recommendedServiceCard(context, "Battery Check", Icons.battery_full),
                            _recommendedServiceCard(context, "Brake Inspection", Icons.car_repair),
                            _recommendedServiceCard(context, "Alignment", Icons.construction),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ===================
            // 3. Insights Section
            // ===================



            // Uncomment to test logout
            // Center(
            //   child: IconButton(
            //     onPressed: () => _handleSignOut(context),
            //     icon: const Icon(Icons.logout),
            //     tooltip: "Logout",
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  /// Builds a row of two dashboard cards
  Widget _buildDashboardRow(BuildContext context, List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children
          .map(
            (widget) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.44,
              child: widget,
            ),
          )
          .toList(),
    );
  }

  /// Dashboard card
  Widget _dashboardCard(BuildContext context, String title, String value) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.inversePrimary,
            theme.colorScheme.inversePrimary.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, color: theme.colorScheme.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Recommended Service Card
  Widget _recommendedServiceCard(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _handleServiceTap(context, label, icon),

      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.inversePrimary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.inversePrimary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.inversePrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
