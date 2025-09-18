import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/common/widgets/charts/fixero_linechart.dart';
import 'package:fixero/features/authentication/controllers/manager_controller.dart';
import 'package:fixero/features/authentication/models/manager.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/item_usage_controller.dart';
import 'package:fixero/features/inventory_management/models/restock_record.dart';
import 'package:fixero/features/inventory_management/views/edit_item_page.dart';
import 'package:fixero/features/inventory_management/views/item_usage_chart_data.dart';
import 'package:fixero/features/inventory_management/views/item_usage_chart_helper.dart';
import 'package:fixero/features/inventory_management/views/request_restock_page.dart';
import 'package:fixero/features/inventory_management/views/restock_item_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDetailsPage extends StatefulWidget {
  final String itemID; // use ID instead of full Item
  const ItemDetailsPage({super.key, required this.itemID});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  Manager? currentManager;
  int _visibleRestockCount = 3;

  List<RestockRecord> _restockRecords = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRestockRecords();
    _loadCurrentManager();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final itemUsageController = context.read<ItemUsageController>();
      await itemUsageController.loadItemUsagesByItemID(widget.itemID);
    });
  }

  Future<void> _fetchRestockRecords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await context.read<ItemController>().getRestockingDetails(
        widget.itemID,
      );

      if (!mounted) return;

      setState(() {
        _restockRecords = records;
        _isLoading = false;
        _visibleRestockCount = records.length >= 3
            ? 3
            : records.length; // reset view count
      });
    } catch (e, stackTrace) {
      if (!mounted) return;

      debugPrint('Error fetching restock records: $e');
      debugPrintStack(stackTrace: stackTrace);

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentManager() async {
    final manager = await ManagerController.getCurrentManager();
    if (!mounted) return;
    setState(() {
      currentManager = manager;
    });
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 184, 13, 1),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm) {
      if (!mounted) return;
      final itemController = context.read<ItemController>();
      await itemController.deleteItem(widget.itemID);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ItemController>();
    final item = controller.getItemByID(widget.itemID); // reactive

    if (item == null) {
      return Scaffold(
        appBar: FixeroSubAppBar(title: "Item Details", showBackButton: true),
        body: const Center(child: Text("Item not found")),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: FixeroSubAppBar(title: item.itemName, showBackButton: true),
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
                            item.itemID,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary
                                  .withValues(alpha: 0.8),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary
                                  .withValues(alpha: 0.8),
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

                          Builder(
                            builder: (context) {
                              final itemUsageController = context
                                  .watch<ItemUsageController>();
                              final itemUsageChartData =
                                  aggregateItemUsageByMonth(
                                    itemUsageController.itemUsages,
                                  );
                              debugPrint(
                                'Chart data: $itemUsageChartData',
                              ); // <-- DEBUG
                              return FixeroLineChart<ItemUsageChartData>(
                                data: itemUsageChartData,
                                color: Colors.green,
                                showDot: true,
                                showGradient: true,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // ------------------ RESTOCKING DETAILS REFINED ------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'RESTOCKING DETAILS',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary.withAlpha(200),
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
                              ).dividerColor.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Loading/Error/Empty States
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (_error != null)
                            Center(child: Text('Error: $_error'))
                          else if (_restockRecords.isEmpty)
                            const Center(
                              child: Text(
                                '( No record )',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            )
                          else
                            // Actual table
                            Column(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Table(
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      border: TableBorder.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                            .withAlpha(80),
                                        width: 1,
                                      ),
                                      columnWidths: {
                                        0: IntrinsicColumnWidth(), // supplier
                                        1: IntrinsicColumnWidth(), // restocked date
                                        2: IntrinsicColumnWidth(), // quantity
                                      },
                                      children: [
                                        TableRow(
                                          decoration: const BoxDecoration(
                                            color: Colors.black12,
                                          ),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Supplier',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Restocked Date',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                'Quantity\n(${item.unit})',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ..._restockRecords
                                            .take(_visibleRestockCount)
                                            .map(
                                              (record) => TableRow(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Text(
                                                      record
                                                          .supplier
                                                          .supplierName,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Text(
                                                      record.order.arrivalDate
                                                          .toString()
                                                          .split(' ')[0],
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Text(
                                                      record
                                                          .requestedItem
                                                          .quantityRequested
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      ],
                                    );
                                  },
                                ),
                                if (_visibleRestockCount <
                                    _restockRecords.length)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _visibleRestockCount =
                                              (_visibleRestockCount + 5).clamp(
                                                0,
                                                _restockRecords.length,
                                              );
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                            .withAlpha(50),
                                      ),
                                      child: const Text(
                                        'View More',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // 🔹 Inside ListView before the closing bracket
                    if (currentManager?.role == "Inventory Manager") ...[
                      ElevatedButton(
                        onPressed: () async {
                          await _deleteItem();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            174,
                            12,
                            0,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10.0,
                          children: [Icon(Icons.delete), Text('Delete')],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20.0),
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
                spacing: 10.0,
                children: [
                  if (currentManager?.role == "Inventory Manager") ...[
                    // 🔹 Edit Info Button
                    Expanded(
                      child: ElevatedButton(
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          spacing: 5.0,
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
                    ),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestockItemPage(item: item),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 15.0,
                          ),
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          spacing: 5.0,
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
                    ),
                  ],

                  if (currentManager?.role == "Workshop Manager") ...[
                    // 🔹 Request Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RequestRestockPage(item: item),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 15.0,
                          ),
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10.0,
                          children: [
                            const Icon(Icons.inventory_outlined, size: 25),
                            Text(
                              'Request Restock',
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
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
