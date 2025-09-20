import 'package:fixero/data/dao/inventory/requested_item_dao.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/order_controller.dart';
import 'package:fixero/features/inventory_management/controllers/requested_item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restock_request_controller.dart';
import 'package:fixero/features/inventory_management/controllers/supplier_controller.dart';
import 'package:fixero/features/inventory_management/models/item.dart';
import 'package:fixero/features/inventory_management/models/order.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';
import 'package:fixero/features/inventory_management/views/request_details_sheet.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetailsSheet extends StatefulWidget {
  final Order order;

  const OrderDetailsSheet({super.key, required this.order});

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  bool _isLoading = true;
  List<RestockRequest> _requests = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemController = context.read<ItemController>();
      final restockController = context.read<RestockRequestController>();

      if (itemController.items.isEmpty) await itemController.loadItems();
      await restockController.loadRequests();

      final orderRequests = restockController.getRequestsByOrderNo(
        widget.order.orderNo,
      );

      if (!mounted) return;
      setState(() {
        _requests = orderRequests;
        _isLoading = false;
      });
    });
  }

  Future<void> _markAsReceived() async {
    if (_requests.isEmpty) return;

    final ratingController = TextEditingController();
    final feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // 1️⃣ Confirm dialog with optional rating & feedback
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mark as Received?"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Rating (0-5, optional)",
                  hintText: "Enter 0 if no rating",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final rating = int.tryParse(value);
                  if (rating == null || rating < 0 || rating > 5) {
                    return "Enter a number between 0 and 5";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: "Feedback (optional)",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final requestedItemController = context.read<RequestedItemController>();
    final itemController = context.read<ItemController>();
    final orderController = context.read<OrderController>();

    try {
      for (var request in _requests) {
        // 🔹 Ensure requested items are loaded
        await requestedItemController.loadItemsByRequestId(request.requestID);

        final pendingItems = requestedItemController.getPendingItems(
          request.requestID,
        );

        for (var reqItem in pendingItems) {
          // 🔹 1. Update requested item status to "Received"
          final updatedReqItem = reqItem.copyWith(status: "Received");
          await requestedItemController.updateRequestedItem(updatedReqItem);

          // 🔹 2. Update actual stock quantity
          if (itemController.items.isEmpty) {
            // Load items if cache is empty
            await itemController.loadItems();
          }

          final item = itemController.getItemByID(reqItem.itemID);
          if (item != null) {
            final updatedItem = item.copyWith(
              stockQuantity: item.stockQuantity + reqItem.quantityRequested,
            );
            await itemController.updateItem(updatedItem);
          } else {
            debugPrint("⚠️ Item not found for ID: ${reqItem.itemID}");
          }
        }
      }

      // 🔹 3. Update the order
      final now = DateTime.now();
      final updatedOrder = widget.order.copyWith(
        arrivalDate:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        rating: int.tryParse(ratingController.text) ?? 0,
        feedback: feedbackController.text.isEmpty
            ? null
            : feedbackController.text,
      );
      await orderController.updateOrder(updatedOrder);

      if (!mounted) return;

      // 🔹 4. Refresh UI
      setState(() => _requests = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order marked as received!")),
      );

      Navigator.of(context).pop(); // Close sheet
    } catch (e) {
      if (!mounted) return;
      debugPrint("❌ Failed to mark as received: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to mark as received: $e")));
    }
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

  Future<String> _getSupplierName(String supplierID) async {
    final supplierController = context.read<SupplierController>();
    final supplier = supplierController.getSupplierByIdSync(supplierID);
    return supplier?.supplierName ?? "Unknown Supplier";
  }

  @override
  Widget build(BuildContext context) {
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty
              ? const Center(child: Text("No requests found for this order"))
              : Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          Text(
                            "Order Details",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, thickness: 1),

                    const SizedBox(height: 20),

                    // Request ID
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        widget.order.orderNo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Theme.of(
                            context,
                          ).textTheme.titleMedium?.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Text(
                            "Order Date: ",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),

                          Text(widget.order.orderDate),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Text(
                            "Order Time: ",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),

                          Text(
                            Formatter.formatTime12Hour(
                              widget.order.orderTime,
                              showSeconds: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Text(
                            "Supplied By: ",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),

                          FutureBuilder<String>(
                            future: _getSupplierName(widget.order.supplierID),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Loading...");
                              }
                              if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              }
                              return Text(
                                snapshot.data ?? "Unknown Supplier",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section title
                            Text(
                              "Approved Request(s)",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),

                            // Requests list
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _requests.length,
                              itemBuilder: (context, index) {
                                final request = _requests[index];

                                return FutureBuilder(
                                  future: Future.wait([
                                    RequestedItemDAO().getItemsByRequestID(
                                      request.requestID,
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
                                        margin: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: ListTile(
                                          title: Text("Loading..."),
                                        ),
                                      );
                                    }

                                    final requestedItems =
                                        snapshot.data![0]
                                            as List<RequestedItem>;
                                    final manager = snapshot.data![1];
                                    final itemController = context
                                        .read<ItemController>();

                                    final itemsForGrid = requestedItems
                                        .map(
                                          (ri) => itemController.getItemByID(
                                            ri.itemID,
                                          ),
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
                                          builder: (context) =>
                                              RequestDetailsSheet(
                                                request: request,
                                                showApproveButton: false,
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
                                          leading: _buildImageGrid(
                                            itemsForGrid,
                                          ),
                                          title: Text(
                                            request.requestID,
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
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 2,
                                                          horizontal: 5,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
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
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5.0,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      Formatter.formatTime12Hour(
                                                        request.requestTime,
                                                      ),
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
                          ],
                        ),
                      ),
                    ),

                    // 🔹 Action button
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: double.infinity, // full width
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              0,
                              145,
                              5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _requests.isEmpty
                              ? null
                              : () async => _markAsReceived(),
                          icon: const Icon(Icons.check),
                          label: const Text("Mark as Received"),
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
