import 'package:fixero/features/authentication/controllers/manager_controller.dart';
import 'package:fixero/features/authentication/models/manager.dart';
import 'package:fixero/features/inventory_management/views/browse_inventory_page.dart';
import 'package:fixero/features/inventory_management/views/restock_orders_page.dart';
import 'package:fixero/features/inventory_management/views/stock_alerts_page.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../../../common/widgets/bars/fixero_main_appbar.dart';

class InventoryPage extends StatefulWidget {
  static const routeName = '/inventory';

  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  Manager? currentManager;

  @override
  void initState() {
    super.initState();
    _loadCurrentManager();
  }

  Future<void> _loadCurrentManager() async {
    final manager = await ManagerController.getCurrentManager();
    if (!mounted) return;
    setState(() {
      currentManager = manager;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int stockAlertCount = 15;
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: FixeroMainAppBar(
          title: "Inventory",
          searchHints: ["Spare Parts", "Tools"],
          searchTerms: [
            "Oil Change",
            "Tire Rotation",
            "Battery Check",
            "Brake Inspection",
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: <Widget>[
            // Stock Alerts
            _buildInventoryOptionCard(
              theme: theme,
              icon: Icons.trolley,
              title: "Stock Alerts",
              badgeCount: stockAlertCount,
              onTap: () {
                // Handle Stock Alert tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StockAlertsPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            Row(
              spacing: 10.0,
              children: [
                // Issue History
                Expanded(
                  child: _buildInventoryOptionCard(
                    theme: theme,
                    icon: Icons.article,
                    title: "Issued History",
                    onTap: () {
                      // Handle Stock Alert tap
                    },
                  ),
                ),

                // Browse Inventory
                Expanded(
                  child: _buildInventoryOptionCard(
                    theme: theme,
                    icon: Icons.article,
                    title: "Browse Inventory",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BrowseInventoryPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (currentManager?.role == "Inventory Manager") ...[
              _buildInventoryOptionCard(
                theme: theme,
                icon: Icons.inventory_2,
                title: "Restock & Orders",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RestockOrdersPage(),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        bottomNavigationBar: FixeroBottomAppBar(),
      ),
    );
  }

  Widget _buildInventoryOptionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none, // so badge can float outside card
        fit: StackFit.passthrough,
        children: [
          Card(
            elevation: 0,
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Icon
                  Icon(icon, size: 50, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  // Title
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (badgeCount > 0)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.pink, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
