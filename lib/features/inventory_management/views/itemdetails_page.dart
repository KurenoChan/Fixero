import 'package:fixero/common/widgets/bars/fixero_subappbar.dart';
import 'package:flutter/material.dart';
import '../models/item_model.dart';

class ItemDetailsPage extends StatelessWidget {
  final Item item;
  const ItemDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixeroSubAppBar(title: item.itemName),
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
                  const SizedBox(height: 8),
                  Text(item.itemDescription),
                  const Divider(height: 24),
                  _buildDetailRow("Category", item.itemCategory),
                  _buildDetailRow("Subcategory", item.itemSubCategory),
                  _buildDetailRow(
                    "Price",
                    "RM${item.itemPrice.toStringAsFixed(2)} / ${item.unit}",
                  ),
                  _buildDetailRow(
                    "Stock",
                    "${item.stockQuantity} (Low threshold: ${item.lowStockThreshold})",
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
                  onPressed: () {},
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
