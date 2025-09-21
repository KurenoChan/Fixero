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

  String _sortCriteria = 'Stock Low-High';

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

    // Apply sorting
    switch (_sortCriteria) {
      case 'Name A-Z':
        filteredItems.sort((a, b) => a.itemName.compareTo(b.itemName));
        break;
      case 'Name Z-A':
        filteredItems.sort((a, b) => b.itemName.compareTo(a.itemName));
        break;
      case 'Price Low-High':
        filteredItems.sort((a, b) => a.itemPrice.compareTo(b.itemPrice));
        break;
      case 'Price High-Low':
        filteredItems.sort((a, b) => b.itemPrice.compareTo(a.itemPrice));
        break;
      case 'Stock Low-High':
        filteredItems.sort(
          (a, b) => a.stockQuantity.compareTo(b.stockQuantity),
        );
        break;
      case 'Stock High-Low':
        filteredItems.sort(
          (a, b) => b.stockQuantity.compareTo(a.stockQuantity),
        );
        break;
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
                  SliverToBoxAdapter(
                    child: // Search bar
                    Padding(
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

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyHeaderDelegate(
                      child: Column(
                        children: [
                          // Filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 10,
                              children: [
                                ChoiceChip(
                                  label: Text("All ($allCount)"),
                                  selected: _filter == StockFilter.all,
                                  onSelected: (_) =>
                                      setState(() => _filter = StockFilter.all),
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                                ChoiceChip(
                                  label: Text("Low Stock ($lowCount)"),
                                  selected: _filter == StockFilter.lowStock,
                                  onSelected: (_) => setState(
                                    () => _filter = StockFilter.lowStock,
                                  ),
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                                ChoiceChip(
                                  label: Text("Out of Stock ($outCount)"),
                                  selected: _filter == StockFilter.outOfStock,
                                  onSelected: (_) => setState(
                                    () => _filter = StockFilter.outOfStock,
                                  ),
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),

                          // Sort dropdown
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                const Text("Sort by: "),
                                const SizedBox(width: 10),
                                DropdownButton<String>(
                                  value: _sortCriteria,
                                  items:
                                      [
                                            'Name A-Z',
                                            'Name Z-A',
                                            'Price Low-High',
                                            'Price High-Low',
                                            'Stock Low-High',
                                            'Stock High-Low',
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
                                      setState(() => _sortCriteria = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
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
  double get maxExtent => 120; // adjust according to your content height
  @override
  double get minExtent => 120;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
