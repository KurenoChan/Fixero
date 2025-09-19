import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/views/stock_alerts_page.dart';
import 'package:fixero/features/job_management/controllers/job_controller.dart';
import 'package:fixero/features/job_management/views/job_demand_chart_helper.dart';
import 'package:fixero/features/job_management/views/service_chart_helper.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/widgets/bars/fixero_bottom_appbar.dart';
import 'common/widgets/bars/fixero_home_appbar.dart';
import 'common/widgets/charts/fixero_barchart.dart';
import 'common/widgets/charts/fixero_linechart.dart';
import 'common/widgets/charts/fixero_piechart.dart';
import 'data/dao/income_dao.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> insightsFilterOptions = const ["This Month", "This Year"];
  // late String _selectedInsightFilter;

  String? _managerName;
  String? _profileImgUrl;

  @override
  void initState() {
    super.initState();
    _loadManagerData();
    // _selectedInsightFilter = insightsFilterOptions[0];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemController = context.read<ItemController>();
      final jobController = context.read<JobController>();

      if (itemController.items.isEmpty) {
        await itemController.loadItems();
        if (!context.mounted) return;
      }

      if (jobController.jobs.isEmpty) {
        await jobController.loadJobs();
        if (!context.mounted) return;
      }
    });
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case "oil change":
        return Icons.oil_barrel; // 🛢️ fits perfectly
      case "battery check":
      case "battery repair":
        return Icons.battery_full; // 🔋 battery
      case "tire rotation":
      case "tire repair":
        return Icons
            .tire_repair; // ⭕ if using Flutter 3.24+, else use Icons.build
      case "brake inspection":
        return Icons.car_repair; // 🚗 mechanic-like
      case "alignment":
      case "vehicle safety check":
        return Icons.rule; // 📏 alignment / inspection
      case "fuel tank maintenance":
        return Icons.local_gas_station; // ⛽ fuel tank
      case "car repair":
        return Icons.build; // 🛠️ general repair
      default:
        return Icons.miscellaneous_services; // ⚙️ fallback
    }
  }

  Future<void> _loadManagerData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final repo = ManagerRepository();
      final manager = await repo.getManager(uid);
      if (mounted && manager != null) {
        setState(() {
          _managerName = manager.name;
          _profileImgUrl = manager.profileImgUrl;
        });
      }
    }
  }

  void _handleServiceTap(BuildContext context, String label, IconData icon) {
    // Example behavior: show a dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: Text("You tapped on $label"),
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
    final itemController = context.watch<ItemController>();
    final jobController = context.watch<JobController>();

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

            // =====================
            // 1. Dashboard Overview
            // =====================

            // Dashboard Rows
            _buildDashboardRow(context, [
              _dashboardCard(
                context,
                "Ongoing Jobs",
                jobController.ongoingJobs.length.toString(),
              ),
              _dashboardCard(context, "Invoices", "5"),
            ]),
            const SizedBox(height: 10),
            _buildDashboardRow(context, [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const StockAlertsPage(filter: StockFilter.lowStock),
                  ),
                ),
                child: _dashboardCard(
                  context,
                  "Low Stock Items",
                  itemController.lowStockItems.length.toString(),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const StockAlertsPage(filter: StockFilter.outOfStock),
                  ),
                ),
                child: _dashboardCard(
                  context,
                  "Out of Stock Items",
                  itemController.outOfStockItems.length.toString(),
                ),
              ),
            ]),

            const SizedBox(height: 40),

            // ======================
            // 2. Services Section
            // ======================
            Column(
              spacing: 10.0,
              children: [
                // Section Title + See All Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Services", style: TextStyle(fontSize: 17)),
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
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       SingleChildScrollView(
                //         scrollDirection: Axis.horizontal,
                //         child: Row(
                //           spacing: 10.0,
                //           children: [
                //             _serviceCard(
                //               context,
                //               "Oil Change",
                //               Icons.oil_barrel,
                //             ),
                //             _serviceCard(
                //               context,
                //               "Tire Rotation",
                //               Icons.sync,
                //             ),
                //             _serviceCard(
                //               context,
                //               "Battery Check",
                //               Icons.battery_full,
                //             ),
                //             _serviceCard(
                //               context,
                //               "Brake Inspection",
                //               Icons.car_repair,
                //             ),
                //             _serviceCard(
                //               context,
                //               "Alignment",
                //               Icons.construction,
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // Service Cards (dynamic)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 10,
                    children: jobController.getJobServiceTypes().map((
                      serviceType,
                    ) {
                      return _serviceCard(
                        context,
                        Formatter.capitalize(serviceType),
                        _getServiceIcon(serviceType),
                      );
                    }).toList(),
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
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   decoration: BoxDecoration(
                //     border: Border(
                //       top: BorderSide(
                //         color: theme.colorScheme.inversePrimary,
                //         width: 1,
                //       ),
                //       right: BorderSide(
                //         color: theme.colorScheme.inversePrimary,
                //         width: 1,
                //       ),
                //       bottom: BorderSide(
                //         color: theme.colorScheme.inversePrimary,
                //         width: 1,
                //       ),
                //       left: BorderSide(
                //         color: theme.colorScheme.inversePrimary,
                //         width: 1,
                //       ),
                //     ),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: FixeroDropdown(
                //     options: insightsFilterOptions,
                //     selectedOption: _selectedInsightFilter,
                //     onChanged: _handleInsightFilterChange,
                //   ),
                // ),

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

                    // 2. Job Demand by year (job.createdAt)
                    _insightsCard(
                      context: context,
                      title: "Job Demand",
                      value: jobController.jobs.length.toString(),
                      trend: getJobDemandTrend(jobController.demandByMonth),
                      chart: FixeroBarChart(
                        data: jobController.demandByMonth,
                        color: const Color.fromRGBO(255, 178, 122, 1.0),
                      ),
                    ),


                    // 3. Popular Service (only chart)
                    _insightsCard(
                      context: context,
                      value: "Popular Services",
                      chart: FixeroPieChart(
                        data: aggregateServicePopularity(jobController.jobs),
                      ),
                      trendColor: theme.colorScheme.inversePrimary,
                    ),
                  ],
                ),
              ],
            ),
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
              width: MediaQuery.of(context).size.width * 0.45,
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
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.primary.withValues(alpha: 0.3),
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
  Widget _serviceCard(BuildContext context, String label, IconData icon) {
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
