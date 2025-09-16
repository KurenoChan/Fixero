import 'package:fixero/data/dao/inventory/requested_item_dao.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/features/authentication/controllers/manager_controller.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/order_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restock_request_controller.dart';
import 'package:fixero/features/inventory_management/controllers/supplier_controller.dart';
import 'package:fixero/features/inventory_management/models/item.dart';
import 'package:fixero/features/inventory_management/models/order.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';
import 'package:fixero/features/inventory_management/models/supplier.dart';
import 'package:fixero/features/inventory_management/views/request_details_sheet.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:fixero/utils/generators/id_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateOrderSheet extends StatefulWidget {
  final List<RestockRequest> approvedRequests;

  const CreateOrderSheet({super.key, required this.approvedRequests});

  @override
  State<CreateOrderSheet> createState() => _CreateOrderSheetState();
}

class _CreateOrderSheetState extends State<CreateOrderSheet> {
  final _formKey = GlobalKey<FormState>();

  List<Supplier> _supplierList = [];
  Supplier? _selectedSupplier;
  bool _isLoadingSuppliers = true;

  /// 🔹 Confirmation dialog for discard
  Future<bool?> _confirmDiscard(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard order'),
        content: const Text('Are you sure you want to discard this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 184, 13, 1),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  /// 🔹 Confirmation dialog for create
  Future<bool?> _confirmCreate(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create order'),
        content: const Text('Do you want to create this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 145, 5),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _discardOrder(BuildContext context) async {
    final confirmed = await _confirmDiscard(context);
    if (confirmed == true) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close sheet
    }
  }

  Future<void> _createOrder(
    BuildContext context,
    List<RestockRequest> selectedRequests,
  ) async {
    // 🔹 Validate supplier dropdown
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await _confirmCreate(context);
    if (confirmed != true || !context.mounted) return;

    try {
      // Step 1: Generate IDs
      final orderNo = IDGenerator.generateOrderNo();
      final supplierId = _selectedSupplier!.supplierID;

      final newOrder = Order(
        orderNo: orderNo,
        orderDate: Formatter.todayDate(),
        supplierID: supplierId,
        // add createdBy if your model supports it
      );

      // 🔹 Add order (updates Firebase + Provider)
      await context.read<OrderController>().addOrder(newOrder);

      // Step 2: Approve requests and link them
      final manager = await ManagerController.getCurrentManager();
      if (manager == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch manager info.")),
        );
        return;
      }

      for (final request in selectedRequests) {
        final updatedRequest = request.copyWith(
          status: "Approved",
          approvedDate: Formatter.todayDate(),
          approvedBy: manager.id,
          orderNo: orderNo,
        );

        // 🔹 Update request (updates Firebase + Provider)
        if (!context.mounted) return;
        await context.read<RestockRequestController>().updateRequest(
          updatedRequest,
        );
      }

      // ✅ Feedback
      if (context.mounted) {
        Navigator.of(context).pop(); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order created successfully")),
        );
      }
    } catch (e) {
      debugPrint("❌ Failed to create order: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to create order: $e")));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemController = context.read<ItemController>();
      final restockController = context.read<RestockRequestController>();
      final supplierController = context.read<SupplierController>();

      if (itemController.items.isEmpty) {
        await itemController.loadItems();
      }
      await restockController.loadRequests();

      // 🔹 Load suppliers
      await supplierController.loadSuppliers();
      if (!mounted) return;

      setState(() {
        _supplierList = supplierController.suppliers;
        _isLoadingSuppliers = false;
      });
    });
  }

  /// 🔹 Shared image grid for up to 4 items
  Widget _buildImageGrid(List<Item?> itemsForGrid) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: 80,
      height: 80,
      child: itemsForGrid.isEmpty
          ? const Center(child: Text("No image"))
          : LayoutBuilder(
              builder: (context, constraints) {
                final count = itemsForGrid.length;

                if (count == 1) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      itemsForGrid[0]!.imageUrl,
                      fit: BoxFit.cover,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('No image')),
                    ),
                  );
                } else if (count == 2) {
                  return Row(
                    spacing: 2.0,
                    children: itemsForGrid.map((item) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.network(
                              item!.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text('No image')),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                } else if (count == 3) {
                  return Column(
                    spacing: 2.0,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 2.0,
                          children: itemsForGrid.take(2).map((item) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2.0),
                                  child: Image.network(
                                    item!.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Text('No image'),
                                            ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3.0),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: Image.network(
                              itemsForGrid[2]!.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text('No image')),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // 4 images
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                    itemCount: 4,
                    itemBuilder: (context, i) {
                      final item = itemsForGrid[i]!;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text('No image')),
                        ),
                      );
                    },
                  );
                }
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restockController = context.watch<RestockRequestController>();
    final itemController = context.read<ItemController>();

    if (restockController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendingRequests = restockController.pendingRequests;
    if (pendingRequests.isEmpty) {
      return const Center(child: Text("No pending requests"));
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 🔹 Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const Text(
                      "Create Order",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // 🔹 Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Supplier dropdown
                        Text(
                          "Select Supplier",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _isLoadingSuppliers
                            ? const Center(child: CircularProgressIndicator())
                            : _supplierList.isEmpty
                            ? const Text("No suppliers available")
                            : DropdownButtonFormField<Supplier>(
                                value: _selectedSupplier,
                                items: _supplierList.map((s) {
                                  return DropdownMenuItem<Supplier>(
                                    value: s,
                                    child: Text(s.supplierName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSupplier = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? "Please select a supplier"
                                    : null,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Choose a supplier",
                                ),
                              ),

                        const SizedBox(height: 20),

                        // 🔹 Approved Requests
                        Text(
                          "Approved Request(s)",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.approvedRequests.length,
                          itemBuilder: (context, index) {
                            final request = widget.approvedRequests[index];

                            return FutureBuilder(
                              future: Future.wait([
                                RequestedItemDAO().getItemsByRequestId(
                                  request.requestId,
                                ),
                                ManagerRepository().getManager(
                                  request.requestBy,
                                ),
                              ]),
                              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                                if (snapshot.hasError) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        "Error loading request: ${snapshot.error}",
                                      ),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData) {
                                  return const Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(title: Text("Loading...")),
                                  );
                                }

                                final requestedItems =
                                    snapshot.data![0] as List<RequestedItem>;
                                final manager = snapshot.data![1];
                                final itemsForGrid = requestedItems
                                    .map(
                                      (ri) =>
                                          itemController.getItemById(ri.itemId),
                                    )
                                    .where((item) => item != null)
                                    .take(4)
                                    .toList();

                                return GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => RequestDetailsSheet(
                                        request: request,
                                        isCreatingOrder: true,
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                      leading: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                        width: 80,
                                        height: 80,
                                        child: itemsForGrid.isEmpty
                                            ? const Center(
                                                child: Text("No image"),
                                              )
                                            : _buildImageGrid(itemsForGrid),
                                      ),
                                      title: Text(
                                        request.requestId,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.fontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        spacing: 5.0,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Theme.of(
                                              context,
                                            ).dividerColor.withAlpha(80),
                                          ),
                                          Row(
                                            spacing: 10.0,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColorLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        5.0,
                                                      ),
                                                ),
                                                child: Text(
                                                  request.requestDate,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.labelSmall,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColorLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        5.0,
                                                      ),
                                                ),
                                                child: Text(
                                                  request.requestTime,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.labelSmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'By: ${manager?.name ?? "Unknown"}',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Action buttons
                        Row(
                          spacing: 20.0,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    184,
                                    13,
                                    1,
                                  ),
                                ),
                                onPressed: () async {
                                  await _discardOrder(context);
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text("Discard"),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    0,
                                    145,
                                    5,
                                  ),
                                ),
                                onPressed: () async {
                                  await _createOrder(
                                    context,
                                    widget.approvedRequests,
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Create"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
