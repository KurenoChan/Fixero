import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/item_usage_controller.dart';
import 'package:fixero/features/inventory_management/models/item.dart';
import 'package:fixero/features/inventory_management/models/item_usage.dart';
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
  String _sortCriteria = 'Latest';

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

  List<ItemUsage> _applySorting(List<ItemUsage> usages) {
    List<ItemUsage> sorted = List.of(usages);

    switch (_sortCriteria) {
      case "Latest":
        sorted.sort((a, b) {
          final dateTimeA = DateTime.parse("${a.usageDate} ${a.usageTime}");
          final dateTimeB = DateTime.parse("${b.usageDate} ${b.usageTime}");
          return dateTimeB.compareTo(dateTimeA); // newest first
        });
        break;

      case "Oldest":
        sorted.sort((a, b) {
          final dateTimeA = DateTime.parse("${a.usageDate} ${a.usageTime}");
          final dateTimeB = DateTime.parse("${b.usageDate} ${b.usageTime}");
          return dateTimeA.compareTo(dateTimeB); // oldest first
        });
        break;

      case "Quantity Low-High":
        sorted.sort((a, b) {
          final qtyA = a.quantityUsed ?? 0;
          final qtyB = b.quantityUsed ?? 0;
          return qtyA.compareTo(qtyB);
        });
        break;

      case "Quantity High-Low":
        sorted.sort((a, b) {
          final qtyA = a.quantityUsed ?? 0;
          final qtyB = b.quantityUsed ?? 0;
          return qtyB.compareTo(qtyA);
        });
        break;
    }

    return sorted;
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

            final itemUsages = _applySorting(usageController.itemUsages);

            return CustomScrollView(
              slivers: [
                // 🔹 Sticky Sorting Dropdown
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      child: Row(
                        children: [
                          const Text("Sort by: "),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: _sortCriteria,
                            items:
                                [
                                      "Latest",
                                      "Oldest",
                                      "Quantity Low-High",
                                      "Quantity High-Low",
                                    ]
                                    .map(
                                      (criteria) => DropdownMenuItem(
                                        value: criteria,
                                        child: Text(criteria),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortCriteria = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final itemUsage = itemUsages[index];
                      final Item? item = itemController.getItemByID(
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
                                  spacing: 15,
                                  children: [
                                    Row(
                                      spacing: 5,
                                      children: [
                                        Icon(Icons.calendar_month, size: 20),
                                        Text(itemUsage.usageDate),
                                      ],
                                    ),
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

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => 60; // adjust based on your dropdown height
  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
