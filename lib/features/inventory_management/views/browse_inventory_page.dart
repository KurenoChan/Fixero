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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
                          fetchData: () => controller.getItemsSync(subCategory),
                          onTap: (context, item) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ItemDetailsPage(itemId: item.itemId),
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

class InventoryListPage<T> extends StatelessWidget {
  final String title;
  final List<T> Function() fetchData; // synchronous fetch from controller
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
      appBar: FixeroSubAppBar(title: title, showBackButton: true,),
      body: Consumer<ItemController>(
        builder: (context, controller, child) {
          final items = fetchData();

          if (items.isEmpty) {
            return Center(child: Text("No $title available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              // 🔹 Category card
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
                        ).colorScheme.primary.withValues(alpha: 0.25),
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

              // 🔹 SubCategory card
              if (isSubCategory && item is String) {
                final firstItem = controller.getFirstItemBySubCategorySync(
                  item,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: () => onTap(context, item),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
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
                                borderRadius: BorderRadius.circular(10),
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              item,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                    color: Theme.of(context).colorScheme.surfaceContainer,
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
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
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
                              style: Theme.of(context).textTheme.bodyMedium,
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: item.stockQuantity == 0
                                        ? Colors.red
                                        : (item.stockQuantity <=
                                                  item.lowStockThreshold
                                              ? Colors.orange
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant),
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
            },
          );
        },
      ),
    );
  }
}

// class InventoryListPage<T> extends StatelessWidget {
//   final String title;
//   final Future<List<T>> Function() fetchData;
//   final void Function(BuildContext context, T item) onTap;
//   final bool isCategory;
//   final bool isSubCategory;

//   const InventoryListPage({
//     super.key,
//     required this.title,
//     required this.fetchData,
//     required this.onTap,
//     this.isCategory = false,
//     this.isSubCategory = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: FixeroSubAppBar(title: title),
//       body: FutureBuilder<List<T>>(
//         future: fetchData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text("No $title available"));
//           }

//           final items = snapshot.data!;
//           return ListView.builder(
//             padding: const EdgeInsets.all(15),
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               final item = items[index];

//               // 🔹 Category card
//               if (isCategory && item is String) {
//                 final icons = {
//                   "Spare Parts": Icons.precision_manufacturing,
//                   "Tools & Equipments": Icons.build,
//                   "Fluids & Lubricants": Icons.water_drop,
//                 };
//                 final icon = icons[item] ?? Icons.category;

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: GestureDetector(
//                     onTap: () => onTap(context, item),
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.primary.withOpacity(0.25),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(
//                             icon,
//                             size: 50,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             item,
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }

//               // 🔹 SubCategory card
//               if (isSubCategory && item is String) {
//                 final controller = Provider.of<ItemController>(
//                   context,
//                   listen: false,
//                 );
//                 return FutureBuilder<Item?>(
//                   future: controller.getFirstItemBySubCategory(item),
//                   builder: (context, snap) {
//                     String? imgUrl;
//                     if (snap.hasData && snap.data != null) {
//                       imgUrl = snap.data!.imageUrl;
//                     }

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: GestureDetector(
//                         onTap: () => onTap(context, item),
//                         child: Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.surfaceContainer,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             children: [
//                               if (imgUrl != null && imgUrl.isNotEmpty)
//                                 Container(
//                                   width: 80,
//                                   height: 80,
//                                   padding: const EdgeInsets.all(5),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Image.network(
//                                     imgUrl,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               else
//                                 Icon(
//                                   Icons.image_not_supported,
//                                   size: 60,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               const SizedBox(width: 15),
//                               Expanded(
//                                 child: Text(
//                                   item,
//                                   style: Theme.of(context).textTheme.titleMedium
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }

//               // 🔹 Item card
//               if (item is Item) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(vertical: 5),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surfaceContainer,
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: ListTile(
//                     leading: Container(
//                       width: 50,
//                       height: 50,
//                       padding: const EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: Image.network(item.imageUrl, fit: BoxFit.cover),
//                     ),
//                     title: Text(
//                       item.itemName,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item.itemId,
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           "RM ${item.itemPrice.toStringAsFixed(2)}/${item.unit}",
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           item.stockQuantity == 0
//                               ? "OUT OF STOCK"
//                               : "${item.stockQuantity} ${item.unit}",
//                           style: TextStyle(
//                             color: item.stockQuantity == 0
//                                 ? Colors.red
//                                 : (item.stockQuantity <= item.lowStockThreshold
//                                       ? Colors.orange
//                                       : Theme.of(
//                                           context,
//                                         ).colorScheme.onSurfaceVariant),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     trailing: const Icon(Icons.chevron_right),
//                     onTap: () => onTap(context, item),
//                   ),
//                 );
//               }

//               return const SizedBox.shrink();
//             },
//           );
//         },
//       ),
//     );
//   }
// }
