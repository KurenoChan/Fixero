import 'package:fixero/common/widgets/tools/fixero_searchbar.dart';
import 'package:fixero/features/inventory_management/views/item_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/bars/fixero_sub_appbar.dart';
import '../../../features/inventory_management/controllers/item_controller.dart';
import '../../../features/inventory_management/models/item.dart';

enum StockFilter { all, lowStock, outOfStock }

class StockAlertsPage extends StatefulWidget {
  final StockFilter filter;

  const StockAlertsPage({super.key, this.filter = StockFilter.all});

  @override
  State<StockAlertsPage> createState() => _StockAlertsPageState();
}

class _StockAlertsPageState extends State<StockAlertsPage> {
  late StockFilter _filter;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _filter = widget.filter;

    // Load items once
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ItemController>().loadItems(),
    );
  }

  List<Item> _applyFilterAndSearch(ItemController controller) {
    List<Item> filteredItems;

    switch (_filter) {
      case StockFilter.lowStock:
        filteredItems = controller.items
            .where(
              (item) =>
                  item.stockQuantity > 0 &&
                  item.stockQuantity <= item.lowStockThreshold,
            )
            .toList();
        break;

      case StockFilter.outOfStock:
        filteredItems = controller.items
            .where((item) => item.stockQuantity == 0)
            .toList();
        break;

      case StockFilter.all:
        filteredItems = controller.items
            .where(
              (item) =>
                  item.stockQuantity == 0 ||
                  item.stockQuantity <= item.lowStockThreshold,
            )
            .toList();
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where(
            (item) => item.itemName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const FixeroSubAppBar(
          title: "Stock Alerts",
          showBackButton: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Consumer<ItemController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredItems = _applyFilterAndSearch(controller);

              // Precompute counts
              final allCount = controller.items
                  .where(
                    (item) =>
                        item.stockQuantity == 0 ||
                        item.stockQuantity <= item.lowStockThreshold,
                  )
                  .length;
              final lowCount = controller.items
                  .where(
                    (item) =>
                        item.stockQuantity > 0 &&
                        item.stockQuantity <= item.lowStockThreshold,
                  )
                  .length;
              final outCount = controller.items
                  .where((item) => item.stockQuantity == 0)
                  .length;

              return CustomScrollView(
                slivers: [
                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: FixeroSearchBar(
                        searchHints: ['Items'],
                        searchTerms: controller.items
                            .map((e) => e.itemName)
                            .toList(),
                        onItemSelected: (selected) {
                          final matchedItem = controller.items.firstWhere(
                            (e) => e.itemName == selected,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ItemDetailsPage(itemID: matchedItem.itemID),
                            ),
                          );
                        },
                        onChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                        },
                      ),
                    ),
                  ),

                  // Filter chips
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _FilterHeaderDelegate(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Wrap(
                          spacing: 10,
                          children: [
                            ChoiceChip(
                              label: Text(
                                "All ($allCount)",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              selected: _filter == StockFilter.all,
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              onSelected: (_) =>
                                  setState(() => _filter = StockFilter.all),
                            ),
                            ChoiceChip(
                              label: Text(
                                "Low Stock ($lowCount)",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              selected: _filter == StockFilter.lowStock,
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              onSelected: (_) => setState(
                                () => _filter = StockFilter.lowStock,
                              ),
                            ),
                            ChoiceChip(
                              label: Text(
                                "Out of Stock ($outCount)",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              selected: _filter == StockFilter.outOfStock,
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              onSelected: (_) => setState(
                                () => _filter = StockFilter.outOfStock,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Item list
                  if (filteredItems.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text("No items found")),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = filteredItems[index];
                        return Container(
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
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item.itemID,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5.0),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    const Icon(Icons.sell, size: 20),
                                    const SizedBox(width: 5),
                                    Text(
                                      "RM ${item.itemPrice.toStringAsFixed(2)}/${item.unit}",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.inventory,
                                      size: 20,
                                      color: item.stockQuantity == 0
                                          ? Colors.red
                                          : (item.stockQuantity <=
                                                    item.lowStockThreshold
                                                ? Colors.orange
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      item.stockQuantity == 0
                                          ? "OUT OF STOCK"
                                          : "${item.stockQuantity} ${item.unit}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: item.stockQuantity == 0
                                                ? Colors.red
                                                : (item.stockQuantity <=
                                                          item.lowStockThreshold
                                                      ? Colors.orange
                                                      : Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ItemDetailsPage(itemID: item.itemID),
                                ),
                              );
                            },
                          ),
                        );
                      }, childCount: filteredItems.length),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

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
  double get maxExtent => 60;
  @override
  double get minExtent => 60;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
