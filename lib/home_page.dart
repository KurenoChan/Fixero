import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';

import 'common/widgets/bars/fixero_bottom_appbar.dart';
import 'common/widgets/bars/fixero_home_appbar.dart';
import 'common/widgets/charts/fixero_barchart.dart';
import 'common/widgets/charts/fixero_piechart.dart';
import 'common/widgets/fixero_dropdown.dart';
import 'data/dao/job_demand_dao.dart';
import 'data/dao/service_dao.dart';

// <-- make sure path matches your file location
import 'features/invoice_management/Views/invoice_module.dart';

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
      final manager = await repo.getManager(uid);
      if (mounted && manager != null) {
        setState(() {
          _managerName = manager.name;
          _profileImgUrl = manager.profileImgUrl;
        });
      }
    }
  }

  void _handleInsightFilterChange(String newFilter) {
    setState(() => _selectedInsightFilter = newFilter);
  }

  // Live stream of UNPAID invoices count from Realtime DB
  Stream<int> _unpaidInvoiceCountStream() {
    final ref = FirebaseDatabase.instance.ref('invoices');
    return ref.onValue.map((event) {
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

  void _handleServiceTap(BuildContext context, String label, IconData icon) {
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
          profileImgUrl: _profileImgUrl ??
              "https://cdn-icons-png.flaticon.com/512/3237/3237476.png",
        ),

        bottomNavigationBar: FixeroBottomAppBar(),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const SizedBox(height: 10),

            // ================
            // Dashboard cards
            // ================
            _buildDashboardRow(context, [
              _dashboardCard(context, "Active Jobs", "10"),
              _dashboardCard(context, "Low Stock Part", "Brake Pads"),
            ]),
            const SizedBox(height: 20),
            _buildDashboardRow(context, [
              // Invoices (UNPAID live count + tap → InvoiceModule)
              StreamBuilder<int>(
                stream: _unpaidInvoiceCountStream(),
                builder: (context, snap) {
                  final unpaid = snap.data ?? 0;
                  return _dashboardCard(
                    context,
                    "Invoices (Unpaid)",
                    unpaid.toString(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InvoiceModule()),
                      );
                    },
                  );
                },
              ),
              _dashboardCard(context, "Appointments", "3"),
            ]),

            const SizedBox(height: 40),

            // ======================
            // Recommended Section
            // ======================
            Column(
              spacing: 10.0,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recommended", style: TextStyle(fontSize: 17)),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.inversePrimary.withValues(alpha: 0.4),
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

            const SizedBox(height: 40),

            // ===============
            // Insights
            // ===============
            Column(
              spacing: 20.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Insights", style: TextStyle(fontSize: 17)),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.inversePrimary,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FixeroDropdown(
                    options: insightsFilterOptions,
                    selectedOption: _selectedInsightFilter,
                    onChanged: _handleInsightFilterChange,
                  ),
                ),

                Column(
                  spacing: 20.0,
                  children: [
                    _insightsCard(
                      context: context,
                      title: "Job Demand",
                      value: "28",
                      trend: "-5%",
                      chart: FixeroBarChart(
                        data: JobDemandDAO.initializeData(),
                        color: const Color.fromRGBO(255, 178, 122, 1.0),
                      ),
                    ),
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
          ],
        ),
      ),
    );
  }

  // ---------- UI helpers ----------

  /// Two-card row
  Widget _buildDashboardRow(BuildContext context, List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children
          .map(
            (w) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.44,
              child: w,
            ),
          )
          .toList(),
    );
  }

  /// Dashboard gradient card (optional onTap)
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

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }

  Widget _recommendedServiceCard(BuildContext context, String label, IconData icon) {
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

  Widget _insightsCard({
    required BuildContext context,
    required Widget chart,
    String? title,
    String? value,
    String? trend,
    Color? trendColor,
  }) {
    final theme = Theme.of(context);
    final effectiveTrendColor = trendColor ??
        (trend != null && trend.startsWith('-')
            ? Colors.red
            : (trend != null && trend.startsWith('+') ? Colors.green : Colors.grey));

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
