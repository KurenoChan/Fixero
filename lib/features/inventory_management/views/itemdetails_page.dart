import 'package:fixero/common/widgets/bars/fixero_subappbar.dart';
import 'package:fixero/features/inventory_management/controllers/inventory_controller.dart';
import 'package:fixero/features/inventory_management/views/edititem_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDetailsPage extends StatelessWidget {
  final String itemId; // use ID instead of full Item
  const ItemDetailsPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();
    final item = controller.getItemById(itemId); // reactive

    if (item == null) {
      return Scaffold(
        appBar: FixeroSubAppBar(title: "Item Details", showBackButton: true,),
        body: const Center(child: Text("Item not found")),
      );
    }
    
    return Scaffold(
      appBar: FixeroSubAppBar(title: item.itemName, showBackButton: true,),
      body: Column(
        children: [
          // 🔹 Image stays at the top
          if (item.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  item.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // 🔹 Bottom sheet-style container for Item Details
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withAlpha(50),
                    blurRadius: 15,
                    offset: const Offset(0, -15),
                  ),
                ],
              ),
              child: ListView(
                children: [
                  // Item Name + ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 220,
                        child: Text(
                          item.itemName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.inverseSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          item.itemId,
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.bodySmall?.fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Item Description
                  Text(item.itemDescription, textAlign: TextAlign.justify),

                  const Divider(height: 24),

                  // Item Price and Stock Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        spacing: 10.0,
                        children: [
                          Icon(Icons.sell, size: 20.0),
                          Text(
                            "RM ${item.itemPrice.toStringAsFixed(2)}/${item.unit}",
                            style: TextStyle(
                              fontSize: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.fontSize,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10.0,
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 20.0,
                            color: item.stockQuantity == 0
                                ? Colors.red
                                : (item.stockQuantity <= item.lowStockThreshold
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
                                  fontSize: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  // Classification
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        Text(
                          'CLASSIFICATION',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Theme.of(
                              context,
                            ).colorScheme.inversePrimary.withValues(alpha: 0.8),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          width: 50.0,
                          child: Divider(
                            height: 1.0,
                            thickness: 1.0,
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.8),
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        Column(
                          spacing: 5.0,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    'Category',
                                    style: TextStyle(
                                      fontSize: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.itemCategory,
                                    style: TextStyle(
                                      fontSize: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.fontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Divider(
                              height: 1.0,
                              thickness: 1.0,
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.8),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    'Subcategory',
                                    style: TextStyle(
                                      fontSize: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.itemSubCategory,
                                    style: TextStyle(
                                      fontSize: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.fontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Usage Overview
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        Text(
                          'USAGE HISTORY',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Theme.of(
                              context,
                            ).colorScheme.inversePrimary.withValues(alpha: 0.8),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          width: 50.0,
                          child: Divider(
                            height: 1.0,
                            thickness: 1.0,
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.8),
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        // Usage History Overview / Details
                        // Mini Tab for Overview (Graph) and Details

                        // Details will display in tabular format
                      ],
                    ),
                  ),

                  // Restocking Details
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        Text(
                          'RESTOCKING DETAILS',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Theme.of(
                              context,
                            ).colorScheme.inversePrimary.withValues(alpha: 0.8),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          width: 50.0,
                          child: Divider(
                            height: 1.0,
                            thickness: 1.0,
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.8),
                          ),
                        ),

                        const SizedBox(height: 10.0),

                        Column(
                          spacing: 20.0,
                          children: [
                            Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              border: TableBorder.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary
                                    .withValues(alpha: 0.8),
                                width: 1,
                              ),
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Text(
                                          'Supplier',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Text(
                                          'Restocked By',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Quantity (${item.unit})',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // if more than 3 restock records
                            // ElevatedButton(
                            //   onPressed: () {},
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Theme.of(
                            //       context,
                            //     ).colorScheme.inversePrimary.withAlpha(50),
                            //   ),
                            //   child: const Text(
                            //     'View More',
                            //     style: TextStyle(fontWeight: FontWeight.normal),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 174, 12, 0),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10.0,
                      children: [Icon(Icons.delete), Text('Delete')],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Bottom sheet-style container for Buttons
          Container(
            height: 100,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.inverseSurface.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditItemPage(item: item),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 10.0,
                    children: [
                      const Icon(Icons.edit, size: 25),
                      Text(
                        'Edit Info',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(
                            context,
                          ).textTheme.titleMedium?.fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 10.0,
                    children: [
                      const Icon(Icons.inventory_outlined, size: 25),
                      Text(
                        'Restock',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(
                            context,
                          ).textTheme.titleMedium?.fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
