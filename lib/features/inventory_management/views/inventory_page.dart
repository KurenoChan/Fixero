import 'package:fixero/features/authentication/controllers/manager_controller.dart';
import 'package:fixero/features/authentication/models/manager.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/views/browse_inventory_page.dart';
import 'package:fixero/features/inventory_management/views/requests_orders_page.dart';
import 'package:fixero/features/inventory_management/views/stock_alerts_page.dart';
import 'package:fixero/features/inventory_management/views/usage_history_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ItemController>().loadItems(),
    );
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
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: FixeroMainAppBar(
          title: "Inventory",
        ),
        body: Consumer<ItemController>(
          builder: (context, itemController, _) {
            // Compute stock counts
            final lowStockCount = itemController.items
                .where(
                  (item) =>
                      item.stockQuantity > 0 &&
                      item.stockQuantity <= item.lowStockThreshold,
                )
                .length;

            final outOfStockCount = itemController.items
                .where((item) => item.stockQuantity == 0)
                .length;

            final totalCount = lowStockCount + outOfStockCount;

            // Determine badge gradient
            final badgeGradient = outOfStockCount > 0
                ? const LinearGradient(
                    colors: [Colors.red, Colors.pink, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Colors.amber, Colors.yellow, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  );

            return ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _buildInventoryOptionCard(
                  theme: theme,
                  icon: Icons.trolley,
                  title: "Stock Alerts",
                  badgeCount: totalCount,
                  badgeGradient: badgeGradient,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StockAlertsPage()),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildInventoryOptionCard(
                        theme: theme,
                        icon: Icons.article,
                        title: "Usage History",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UsageHistoryPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInventoryOptionCard(
                        theme: theme,
                        icon: Icons.article,
                        title: "Browse Inventory",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BrowseInventoryPage(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (currentManager?.role == "Inventory Manager")
                  _buildInventoryOptionCard(
                    theme: theme,
                    icon: Icons.inventory_2,
                    title: "Requests & Orders",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequestsOrdersPage(),
                      ),
                    ),
                  ),
              ],
            );
          },
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
    Gradient? badgeGradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          Card(
            elevation: 0,
            color: theme.colorScheme.primary.withAlpha(90),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(icon, size: 50, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: const TextStyle(
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
                  gradient: badgeGradient,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
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
