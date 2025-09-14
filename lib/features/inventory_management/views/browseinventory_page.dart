import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'package:fixero/common/widgets/bars/fixero_subappbar.dart';
import '../controllers/inventory_controller.dart';
import 'itemdetails_page.dart';

class InventoryListPage<T> extends StatelessWidget {
  final String title;
  final Future<List<T>> Function() fetchData;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixeroSubAppBar(title: title),
      body: FutureBuilder<List<T>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No $title available"));
          }

          final items = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(15),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];

                    // 🔹 Category cards
                    if (isCategory && item is String) {
                      final icons = {
                        "Spare Parts": Icons.precision_manufacturing,
                        "Tools & Equipments": Icons.build,
                        "Fluids & Lubricants": Icons.water_drop,
                      };
                      final icon = icons[item] ?? Icons.category;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap: () => onTap(context, item),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  icon,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // 🔹 SubCategory cards (use first item’s image)
                    if (isSubCategory && item is String) {
                      final controller = InventoryController();
                      return FutureBuilder<Item?>(
                        future: controller.getFirstItemBySubCategory(item),
                        builder: (context, snap) {
                          String? imgUrl;
                          if (snap.hasData && snap.data != null) {
                            imgUrl = snap.data!.imageUrl;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: GestureDetector(
                              onTap: () => onTap(context, item),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  spacing: 20.0,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (imgUrl != null && imgUrl.isNotEmpty)
                                      Container(
                                        width: 80,
                                        height: 80,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                        child: Image.network(
                                          imgUrl,
                                          height: double.infinity,
                                          width: double.infinity,
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

                                    Text(
                                      item,
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),

                                    const Expanded(child: SizedBox()),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    // 🔹 Items (ListTile)
                    else if (item is Item) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
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
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Column(
                            spacing: 1.0,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item.itemId,
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
                            spacing: 5.0,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 5.0,
                                children: [
                                  Icon(Icons.sell, size: 20.0),
                                  Text(
                                    "RM ${item.itemPrice.toStringAsFixed(2)}/${item.unit}",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),

                              Row(
                                spacing: 5.0,
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: 20.0,
                                    color: item.stockQuantity == 0
                                        ? Colors.red
                                        : (item.stockQuantity <=
                                                  item.lowStockThreshold
                                              ? Colors.orange
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant),
                                  ),
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
                          onTap: () => onTap(context, item),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  }, childCount: items.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BrowseInventoryPage extends StatelessWidget {
  const BrowseInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InventoryController();

    return InventoryListPage<String>(
      title: "Categories",
      isCategory: true,
      fetchData: controller.getCategories,
      onTap: (context, category) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InventoryListPage<String>(
              title: category,
              isSubCategory: true,
              fetchData: () => controller.getSubCategories(category),
              onTap: (context, subCategory) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventoryListPage<Item>(
                      title: subCategory,
                      fetchData: () => controller.getItems(subCategory),
                      onTap: (context, item) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemDetailsPage(item: item),
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
  }
}



// import 'package:fixero/common/widgets/bars/fixero_subappbar.dart';
// import 'package:fixero/common/widgets/tools/fixero_searchbar.dart';
// import 'package:flutter/material.dart';

// class BrowseInventoryPage extends StatefulWidget {
//   const BrowseInventoryPage({super.key});

//   @override
//   State<BrowseInventoryPage> createState() => _BrowseInventoryPageState();
// }

// class _BrowseInventoryPageState extends State<BrowseInventoryPage> {
//   final List<Map<String, dynamic>> _itemCategories = [
//     {"name": "Spare Parts", "icon": Icons.precision_manufacturing},
//     {"name": "Tools & Equipments", "icon": Icons.build},
//     {"name": "Fluids & Lubricants", "icon": Icons.water_drop},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: FixeroSubAppBar(title: "Browse Inventory"),
//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: CustomScrollView(
//           slivers: <Widget>[
//             // Search bar
//             SliverToBoxAdapter(
//               child: FixeroSearchBar(
//                 searchHints: ["Spare Parts", "Tools"],
//                 searchTerms: [],
//                 // onSearch: (text) {
//                 //   setState(() {
//                 //     _query = text;
//                 //   });
//                 // },
//               ),
//             ),

//             // Title
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20),
//                 child: Text(
//                   "Category",
//                   style: TextStyle(
//                     fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.inversePrimary.withValues(alpha: 0.5),
//                   ),
//                 ),
//               ),
//             ),

//             _itemCategories.isEmpty
//                 ? SliverToBoxAdapter(
//                     child: Center(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Text(
//                           "No categories available.",
//                           style: TextStyle(
//                             fontSize: Theme.of(
//                               context,
//                             ).textTheme.bodyLarge?.fontSize,
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.onSurface.withValues(alpha: 0.5),
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 : SliverList(
//                     delegate: SliverChildBuilderDelegate((
//                       BuildContext context,
//                       int index,
//                     ) {
//                       final category = _itemCategories[index];
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: _itemCategoryCard(
//                           context,
//                           category["name"]!,
//                           category["icon"]!,
//                         ),
//                       );
//                     }, childCount: _itemCategories.length),
//                   ),

//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget _itemCategoryCard(
//   BuildContext context,
//   String categoryName,
//   IconData icon,
// ) {
//   return GestureDetector(
//     onTap: () => {
//       // handle on tap
//     },

//     child: Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Column(
//         children: [
//           // Icon
//           Icon(icon, size: 50, color: Theme.of(context).colorScheme.primary),
//           // Category Name
//           Text(
//             categoryName,
//             style: TextStyle(
//               fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }


// /// Simple reusable card
// Widget _inventoryCard(
//   BuildContext context,
//   String name,
//   IconData? icon,
//   VoidCallback onTap,
// ) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Column(
//         children: [
//           if (icon != null)
//             Icon(icon, size: 50, color: Theme.of(context).colorScheme.primary),
//           Text(
//             name,
//             style: TextStyle(
//               fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }