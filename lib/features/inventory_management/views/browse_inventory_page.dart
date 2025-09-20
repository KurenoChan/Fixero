import 'package:fixero/common/widgets/tools/fixero_searchbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import '../controllers/item_controller.dart';
import 'item_details_page.dart';

class BrowseInventoryPage extends StatefulWidget {
  const BrowseInventoryPage({super.key});

  @override
  State<BrowseInventoryPage> createState() => _BrowseInventoryPageState();
}

class _BrowseInventoryPageState extends State<BrowseInventoryPage> {
  late ItemController controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<ItemController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadItems());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return SafeArea(
            child: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return InventoryListPage<String>(
          title: "Categories",
          isCategory: true,
          fetchData: () => controller.getCategoriesSync(),
          onTap: (context, category) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InventoryListPage<String>(
                  title: category,
                  isSubCategory: true,
                  fetchData: () => controller.getSubCategoriesSync(category),
                  onTap: (context, subCategory) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InventoryListPage<Item>(
                          title: subCategory,
                          fetchData: () =>
                              controller.getItemsBySubCategorySync(subCategory),
                          onTap: (context, item) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ItemDetailsPage(itemID: item.itemID),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class InventoryListPage<T> extends StatefulWidget {
  final String title;
  final List<T> Function() fetchData; // synchronous fetch
  final void Function(BuildContext context, T item) onTap;
  final bool isCategory;
  final bool isSubCategory;

  const InventoryListPage({
    super.key,
    required this.title,
    required this.fetchData,
    required this.onTap,
    this.isCategory = false,
    this.isSubCategory = false,
  });

  @override
  State<InventoryListPage<T>> createState() => _InventoryListPageState<T>();
}

class _InventoryListPageState<T> extends State<InventoryListPage<T>> {
  late List<T>
  _allItems; // current screen items (categories/subcategories/items)
  late List<T> _filteredItems;
  late List<Item> allSearchableItems; // all items for global search

  String _sortCriteria = 'Name A-Z';

  @override
  void initState() {
    super.initState();
    _allItems = widget.fetchData();
    _filteredItems = List.from(_allItems);

    // Fetch all items for global search
    final controller = Provider.of<ItemController>(context, listen: false);
    allSearchableItems = controller.getAllItemsSync(); // returns List<Item>
  }

  void _onSearch(String query) {
    setState(() {
      _filteredItems = _allItems.where((item) {
        if (item is Item) {
          return item.itemName.toLowerCase().contains(query.toLowerCase());
        }
        if (item is String) {
          return item.toLowerCase().contains(query.toLowerCase());
        }
        return false;
      }).toList();
    });
  }

  void _sortItems(String criteria) {
    setState(() {
      if (criteria == 'Name A-Z') {
        _filteredItems.sort((a, b) {
          if (a is Item && b is Item) {
            return a.itemName.compareTo(b.itemName);
          }
          return 0;
        });
      } else if (criteria == 'Name Z-A') {
        _filteredItems.sort((a, b) {
          if (a is Item && b is Item) {
            return b.itemName.compareTo(a.itemName);
          }
          return 0;
        });
      } else if (criteria == 'Price Low-High') {
        _filteredItems.sort((a, b) {
          if (a is Item && b is Item) {
            return a.itemPrice.compareTo(b.itemPrice);
          }
          return 0;
        });
      } else if (criteria == 'Price High-Low') {
        _filteredItems.sort((a, b) {
          if (a is Item && b is Item) {
            return b.itemPrice.compareTo(a.itemPrice);
          }
          return 0;
        });
      }
      _sortCriteria = criteria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: FixeroSubAppBar(title: widget.title, showBackButton: true),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FixeroSearchBar(
                searchHints: ['Items'],
                searchTerms: allSearchableItems.map((e) => e.itemName).toList(),
                onItemSelected: (selected) {
                  final matchedItem = allSearchableItems.firstWhere(
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
                onChanged: _onSearch,
              ),
            ),

            if (_filteredItems.isNotEmpty && _filteredItems.first is Item)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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
                          ].map((criteria) {
                            return DropdownMenuItem(
                              value: criteria,
                              child: Text(criteria),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) _sortItems(value);
                      },
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(child: Text("No ${widget.title} available"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];

                        // 🔹 Category card
                        if (widget.isCategory && item is String) {
                          final icons = {
                            "Spare Parts": Icons.precision_manufacturing,
                            "Tools & Equipments": Icons.build,
                            "Fluids & Lubricants": Icons.water_drop,
                          };
                          final icon = icons[item] ?? Icons.category;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: GestureDetector(
                              onTap: () => widget.onTap(context, item),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      icon,
                                      size: 50,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        // 🔹 SubCategory card
                        if (widget.isSubCategory && item is String) {
                          final controller = Provider.of<ItemController>(
                            context,
                            listen: false,
                          );
                          final firstItem = controller
                              .getFirstItemBySubCategorySync(item);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: GestureDetector(
                              onTap: () => widget.onTap(context, item),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    if (firstItem != null &&
                                        firstItem.imageUrl.isNotEmpty)
                                      Container(
                                        width: 80,
                                        height: 80,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Image.network(
                                          firstItem.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 60,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        // 🔹 Item card
                        if (item is Item) {
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
                              title: Text(
                                item.itemName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "RM ${item.itemPrice.toStringAsFixed(2)}/${item.unit}",
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => widget.onTap(context, item),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
