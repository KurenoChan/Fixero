import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';

import 'common/widgets/bars/fixero_bottomappbar.dart';
import 'common/widgets/bars/fixero_homeappbar.dart';
import 'common/widgets/charts/fixero_barchart.dart';
import 'common/widgets/charts/fixero_linechart.dart';
import 'common/widgets/charts/fixero_piechart.dart';
import 'common/widgets/fixero_dropdown.dart';
import 'data/dao/income_dao.dart';
import 'data/dao/jobdemand_dao.dart';
import 'data/dao/service_dao.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> insightsFilterOptions = const ["This Month", "This Year"];
  late String _selectedInsightFilter;

  String? _managerName;
  String? _profileImgUrl;

  @override
  void initState() {
    super.initState();
    _loadManagerData();
    _selectedInsightFilter = insightsFilterOptions[0];
  }

  Future<void> _loadManagerData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final repo = ManagerRepository();
      final manager = await repo.getManager(uid); // correct method name
      if (mounted && manager != null) {
        setState(() {
          _managerName = manager.name;
          _profileImgUrl =
              manager.profileImgUrl ??
              "https://cdn-icons-png.flaticon.com/512/3237/3237476.png";
        });
      }
    }
  }

  void _handleInsightFilterChange(String newFilter) {
    setState(() {
      _selectedInsightFilter = newFilter;
      // TODO: Update data or charts based on newFilter
    });
  }

  // Future<void> _handleSignOut(BuildContext context) async {
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
        appBar: FixeroHomeAppBar(
          username: Formatter.capitalize(_managerName ?? "Loading..."),

          profileImgUrl:
              _profileImgUrl ??
              "https://cdn-icons-png.flaticon.com/512/3237/3237476.png",
        ),

        bottomNavigationBar: FixeroBottomAppBar(),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const SizedBox(height: 10),

            // Image.network(
            //   'https://www.boschautoparts.com/o/commerce-media/accounts/-1/images/2220845',
            //   height: 200, // optional
            //   fit: BoxFit.cover, // optional
            // ),

            
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
                            .withValues(alpha: 0.4),
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
                            _recommendedServiceCard(
                              context,
                              "Oil Change",
                              Icons.oil_barrel,
                            ),
                            _recommendedServiceCard(
                              context,
                              "Tire Rotation",
                              Icons.sync,
                            ),
                            _recommendedServiceCard(
                              context,
                              "Battery Check",
                              Icons.battery_full,
                            ),
                            _recommendedServiceCard(
                              context,
                              "Brake Inspection",
                              Icons.car_repair,
                            ),
                            _recommendedServiceCard(
                              context,
                              "Alignment",
                              Icons.construction,
                            ),
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
            Column(
              spacing: 20.0,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                const Text("Insights", style: TextStyle(fontSize: 17)),

                // Insights Filter Dropdown (This Month / This Year)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.inversePrimary,
                        width: 1,
                      ),
                      right: BorderSide(
                        color: theme.colorScheme.inversePrimary,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: theme.colorScheme.inversePrimary,
                        width: 1,
                      ),
                      left: BorderSide(
                        color: theme.colorScheme.inversePrimary,
                        width: 1,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FixeroDropdown(
                    options: insightsFilterOptions,
                    selectedOption: _selectedInsightFilter,
                    onChanged: _handleInsightFilterChange,
                  ),
                ),

                // Insights Cards List
                Column(
                  spacing: 20.0,
                  children: [
                    // 1. Income
                    _insightsCard(
                      context: context,
                      title: "Income",
                      value: "RM 10,135",
                      trend: "+8%",
                      chart: FixeroLineChart(
                        data: IncomeDAO.initializeData(),
                        color: Colors.teal,
                      ),
                    ),

                    // 2. Job Demand
                    _insightsCard(
                      context: context,
                      title: "Job Demand",
                      value: "28",
                      trend: "-5%",
                      chart: FixeroBarChart(
                        data: JobDemandDAO.initializeData(),
                        color: Color.fromRGBO(255, 178, 122, 1.0),
                      ),
                    ),

                    // 3. Popular Service (only chart)
                    _insightsCard(
                      context: context,
                      value: "Popular Services",
                      chart: FixeroPieChart(data: ServiceDAO.initializeData()),
                      trendColor: theme.colorScheme.inversePrimary,
                    ),
                  ],
                ),
              ],
            ),

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
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.inversePrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.inversePrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Recommended Service Card
  Widget _recommendedServiceCard(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _handleServiceTap(context, label, icon),

      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.primary),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// Insights Card
  Widget _insightsCard({
    required BuildContext context,
    required Widget chart,
    String? title, // e.g., "Income"
    String? value, // e.g., "RM 10,135"
    String? trend, // e.g., "+8%" or "-5%"
    Color? trendColor, // Optional override
  }) {
    final theme = Theme.of(context);

    // Auto-determine color if not provided
    Color effectiveTrendColor =
        trendColor ??
        (trend != null && trend.startsWith('-')
            ? Colors.red
            : (trend != null && trend.startsWith('+')
                  ? Colors.green
                  : Colors.grey));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.inversePrimary.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || value != null || trend != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Value
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (value != null)
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      if (title != null)
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),

                  // Trend %
                  if (trend != null)
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: effectiveTrendColor,
                      ),
                    ),
                ],
              ),
            ),

          // Chart Section
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 320),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}
