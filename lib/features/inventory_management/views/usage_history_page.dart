import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/item_usage_controller.dart';
import 'package:fixero/features/inventory_management/models/item.dart';
import 'package:fixero/features/inventory_management/views/usage_details_page.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsageHistoryPage extends StatefulWidget {
  const UsageHistoryPage({super.key});

  @override
  State<UsageHistoryPage> createState() => _UsageHistoryPageState();
}

class _UsageHistoryPageState extends State<UsageHistoryPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemUsageController = context.read<ItemUsageController>();
      final itemController = context.read<ItemController>();

      itemUsageController.loadItemUsages();

      if (itemController.items.isEmpty) {
        itemController.loadItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const FixeroSubAppBar(
          title: "Usage History",
          showBackButton: true,
        ),
        body: Consumer<ItemUsageController>(
          builder: (context, usageController, child) {
            if (usageController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (usageController.itemUsages.isEmpty) {
              return const Center(child: Text("No usage history available"));
            }

            final itemController = context.read<ItemController>();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(15),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final itemUsage = usageController.itemUsages[index];
                      final Item? item = itemController.getItemById(
                        itemUsage.itemID,
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UsageDetailsPage(usage: itemUsage),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: item != null && item.imageUrl.isNotEmpty
                                  ? Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.inventory,
                                      color: Colors.grey,
                                    ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item?.itemName ?? "Unknown Item",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  itemUsage.itemUsageNo,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 5.0),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            ),
                            subtitle: Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 5,
                                  children: [
                                    Icon(Icons.access_time, size: 20),
                                    Text(
                                      Formatter.formatTime12Hour(
                                        itemUsage.usageTime,
                                      ),
                                    ),
                                  ],
                                ),

                                if (itemUsage.quantityUsed != null)
                                  Row(
                                    spacing: 5,
                                    children: [
                                      Icon(Icons.inventory, size: 20),
                                      Text(
                                        "${itemUsage.quantityUsed} ${item?.unit ?? ""}",
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      );
                    }, childCount: usageController.itemUsages.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
