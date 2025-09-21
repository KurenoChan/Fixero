import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/views/stock_alerts_page.dart';
import 'package:fixero/features/invoice_management/Views/invoice_module.dart';
import 'package:fixero/features/job_management/controllers/job_controller.dart';
import 'package:fixero/features/job_management/views/job_demand_chart_helper.dart';
import 'package:fixero/features/job_management/views/service_chart_helper.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/widgets/bars/fixero_bottom_appbar.dart';
import 'common/widgets/bars/fixero_home_appbar.dart';
import 'common/widgets/charts/fixero_barchart.dart';
import 'common/widgets/charts/fixero_piechart.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _managerName;
  String? _profileImgUrl;

  Stream<int>? _unpaidInvoicesStream;

  @override
  void initState() {
    super.initState();
    _unpaidInvoicesStream = _unpaidInvoiceCountStream();
    _loadManagerData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemController = context.read<ItemController>();
      final jobController = context.read<JobController>();

      if (itemController.items.isEmpty) {
        await itemController.loadItems();
        if (!context.mounted) return;
      }

      debugPrint(jobController.jobs.isEmpty.toString());
      if (jobController.jobs.isEmpty) {
        await jobController.loadJobs();
        if (!context.mounted) return;
        debugPrint(jobController.jobs.length.toString());
      }
    });
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

  // Live stream of UNPAID invoices count from Realtime DB
  Stream<int> _unpaidInvoiceCountStream() {
    final ref = FirebaseDatabase.instance.ref('invoices');
    return ref.onValue
        .asBroadcastStream() // 🔑 make it reusable
        .map((event) {
          final raw = event.snapshot.value;
          if (raw is Map) {
            int count = 0;
            raw.forEach((_, v) {
              if (v is Map) {
                final status = (v['status'] ?? '').toString().toLowerCase();
                if (status == 'unpaid') count++;
              }
            });
            return count;
          }
          return 0;
        });
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
              // Invoices (UNPAID live count + tap → InvoiceModule)
              StreamBuilder<int>(
                stream: _unpaidInvoicesStream,
                builder: (context, snap) {
                  final unpaid = snap.data ?? 0;
                  return _dashboardCard(
                    context,
                    "Invoices (Unpaid)",
                    unpaid.toString(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InvoiceModule(),
                        ),
                      );
                    },
                  );
                },
              ),
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

            // const SizedBox(height: 40),

            // ======================
            // 2. Services Section
            // ======================
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

                // Insights Cards List
                Column(
                  spacing: 20.0,
                  children: [
                    // 1. Job Demand by year
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

                    // 2. Popular Service
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
  Widget _dashboardCard(
    BuildContext context,
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    final card = Container(
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

    return onTap == null ? card : GestureDetector(onTap: onTap, child: card);
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
