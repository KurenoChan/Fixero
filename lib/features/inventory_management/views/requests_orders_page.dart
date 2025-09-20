import 'package:fixero/data/dao/inventory/requested_item_dao.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/features/authentication/controllers/manager_controller.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/order_controller.dart';
import 'package:fixero/features/inventory_management/controllers/requested_item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restock_request_controller.dart';
import 'package:fixero/features/inventory_management/controllers/supplier_controller.dart';
import 'package:fixero/features/inventory_management/models/order.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';
import 'package:fixero/features/inventory_management/views/create_order_sheet.dart';
import 'package:fixero/features/inventory_management/views/order_details_sheet.dart';
import 'package:fixero/features/inventory_management/views/request_details_sheet.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/bars/fixero_sub_appbar.dart';

class RequestsOrdersPage extends StatefulWidget {
  const RequestsOrdersPage({super.key});

  @override
  State<RequestsOrdersPage> createState() => _RequestsOrdersPageState();
}

class _RequestsOrdersPageState extends State<RequestsOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'Pending Requests'),
    Tab(text: 'Pending Orders'),
  ];

  String _requestSort = "Latest";
  String _orderSort = "Latest";

  Future<void> _rejectRequest(
    BuildContext context,
    RestockRequest request,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject request'),
        content: const Text('Are you sure you want to reject this request?'),
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
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      // 👇 Second dialog to enter remark
      final TextEditingController remarkController = TextEditingController();
      final remark = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rejection Remark'),
          content: TextField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: "Reason for rejection",
              hintText: "Enter remark...",
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 184, 13, 1),
              ),
              onPressed: () =>
                  Navigator.pop(context, remarkController.text.trim()),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (remark == null) return; // user cancelled

      final manager = await ManagerController.getCurrentManager();

      if (manager == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch manager info.")),
        );
        return;
      }

      if (!context.mounted) return;

      // 1️⃣ Reject the request itself
      await context.read<RestockRequestController>().rejectRequest(
        request,
        manager.id,
      );

      // 2️⃣ Update all requested items with remark
      final itemDAO = RequestedItemDAO();
      final requestedItems = await itemDAO.getItemsByRequestID(
        request.requestID,
      );

      for (final item in requestedItems) {
        final updatedItem = item.copyWith(
          status: "Not Processed",
          remark: remark.isNotEmpty ? remark : "Request rejected",
        );
        await itemDAO.updateRequestedItem(updatedItem);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request rejected successfully.")),
      );
    }
  }

  Future<void> _approveRequest(
    BuildContext context,
    RestockRequest request,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve request'),
        content: const Text('Are you sure you want to approve this request?'),
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
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;

      // ✅ Open the CreateOrderSheet as a bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CreateOrderSheet(approvedRequests: [request]),
      );
    }
  }

  Future<String> _getSupplierName(String supplierID) async {
    final supplierController = context.read<SupplierController>();
    final supplier = supplierController.getSupplierByIdSync(supplierID);
    return supplier?.supplierName ?? "Unknown Supplier";
  }

  Future<void> _markOrderAsReceived(BuildContext context, Order order) async {
    if (!context.mounted) return;

    final ratingController = TextEditingController();
    final feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // 1️⃣ Confirm dialog
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

    if (confirmed != true || !context.mounted) return;

    final requestedItemController = context.read<RequestedItemController>();
    final itemController = context.read<ItemController>();
    final orderController = context.read<OrderController>();
    final restockController = context.read<RestockRequestController>();

    try {
      // 2️⃣ Get all requests for this order
      final requests = restockController.getRequestsByOrderNo(order.orderNo);

      for (var request in requests) {
        // Ensure requested items are loaded
        await requestedItemController.loadItemsByRequestId(request.requestID);

        final pendingItems = requestedItemController.getPendingItems(
          request.requestID,
        );

        for (var reqItem in pendingItems) {
          // 🔹 Update requested item status to "Received"
          final updatedReqItem = reqItem.copyWith(status: "Received");
          await requestedItemController.updateRequestedItem(updatedReqItem);

          // 🔹 Update actual stock quantity
          if (itemController.items.isEmpty) {
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

      // 3️⃣ Update the order
      final now = DateTime.now();
      final updatedOrder = order.copyWith(
        arrivalDate:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        rating: int.tryParse(ratingController.text) ?? 0,
        feedback: feedbackController.text.isEmpty
            ? null
            : feedbackController.text,
      );
      await orderController.updateOrder(updatedOrder);

      if (!context.mounted) return;

      // 4️⃣ Refresh UI
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order marked as received!")),
      );
    } catch (e) {
      if (!context.mounted) return;
      debugPrint("❌ Failed to mark order as received: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to mark as received: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final supplierController = context.read<SupplierController>();
      if (supplierController.suppliers.isEmpty) {
        await supplierController.loadSuppliers();
        if (!mounted) return;
      }

      final orderController = context.read<OrderController>();
      final itemController = context.read<ItemController>();
      final restockController = context.read<RestockRequestController>();

      if (itemController.items.isEmpty) {
        await itemController.loadItems();
        if (!mounted) return;
      }

      if (orderController.orders.isEmpty) {
        await orderController.loadOrders();
        if (!mounted) return;
      }

      await restockController.loadRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Placeholder list widgets for now
  Widget _buildPendingRequests() {
    final restockController = context.watch<RestockRequestController>();
    final itemController = context.read<ItemController>();

    if (restockController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendingRequests = [...restockController.pendingRequests]
      ..sort((a, b) {
        final aDateTime = DateTime.parse("${a.requestDate} ${a.requestTime}");
        final bDateTime = DateTime.parse("${b.requestDate} ${b.requestTime}");

        if (_requestSort == "Latest") {
          return bDateTime.compareTo(aDateTime);
        } else {
          return aDateTime.compareTo(bDateTime);
        }
      });

    if (pendingRequests.isEmpty) {
      return const Center(child: Text("No pending requests"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];

        return FutureBuilder(
          future: Future.wait([
            RequestedItemDAO().getItemsByRequestID(request.requestID),
            ManagerRepository().getManager(request.requestBy),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text("Error loading request: ${snapshot.error}"),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(title: Text("Loading...")),
              );
            }

            final requestedItems = snapshot.data![0] as List<RequestedItem>;
            final manager = snapshot.data![1];

            // Map requested items to actual items, filtering invalid images
            final itemsForGrid = requestedItems
                .map((ri) => itemController.getItemByID(ri.itemID))
                .where((item) => item != null)
                .take(4) // max 4 items
                .toList();

            return GestureDetector(
              onTap: () {
                // show bottom sheet of the request details with all the requested items for that request
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // allows full screen
                  backgroundColor: Colors.transparent,
                  builder: (context) => RequestDetailsSheet(request: request),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(5),
                  leading: Container(
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Text('No image'),
                                            ),
                                  ),
                                );
                              } else if (count == 2) {
                                return Row(
                                  spacing: 2.0,
                                  children: itemsForGrid
                                      .map(
                                        (item) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(1),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: Image.network(
                                                width: double.infinity,
                                                height: double.infinity,
                                                item!.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Center(
                                                      child: Text('No image'),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              } else if (count == 3) {
                                return Column(
                                  spacing: 2.0,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        spacing: 2.0,
                                        children: itemsForGrid
                                            .take(2)
                                            .map(
                                              (item) => Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    1,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2.0,
                                                        ),
                                                    child: Image.network(
                                                      item!.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Center(
                                                            child: Text(
                                                              'No image',
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          3.0,
                                        ),
                                        child: SizedBox(
                                          width: constraints.maxWidth,
                                          child: Image.network(
                                            itemsForGrid[2]!.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: Text('No image'),
                                                    ),
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
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Text('No image'),
                                                ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.3),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                request.requestDate,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ),

                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                Formatter.formatTime12Hour(request.requestTime),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'By: ${manager?.name ?? "Unknown"}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _rejectRequest(context, request);
                        },
                        icon: Icon(
                          Icons.close,
                          color: const Color.fromARGB(255, 184, 13, 1),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _approveRequest(context, request);
                        },
                        icon: Icon(
                          Icons.check,
                          color: const Color.fromARGB(255, 0, 145, 5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingOrders() {
    final orderController = context.watch<OrderController>();

    if (orderController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    var pendingOrders = orderController.orders
        .where((order) => order.arrivalDate == null)
        .toList();

    // Apply sort
    pendingOrders.sort((a, b) {
      final aDateTime = DateTime.parse("${a.orderDate} ${a.orderTime}");
      final bDateTime = DateTime.parse("${b.orderDate} ${b.orderTime}");
      if (_orderSort == "Latest") {
        return bDateTime.compareTo(aDateTime);
      } else {
        return aDateTime.compareTo(bDateTime);
      }
    });

    if (pendingOrders.isEmpty) {
      return const Center(child: Text("No pending orders"));
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final order = pendingOrders[index];

              return GestureDetector(
                onTap: () {
                  // show order details bottom sheet
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // allows full screen
                    backgroundColor: Colors.transparent,
                    builder: (context) => OrderDetailsSheet(order: order),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long, size: 30),
                    title: Text(
                      order.orderNo,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.titleMedium?.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Divider(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.3),
                            height: 1,
                            thickness: 1,
                          ),
                        ),

                        Row(
                          spacing: 5.0,
                          children: [
                            Icon(Icons.calendar_month, size: 20),
                            Expanded(
                              child: Text(
                                order.orderDate,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          spacing: 5.0,
                          children: [
                            Icon(Icons.access_time, size: 20),
                            Expanded(
                              child: Text(
                                Formatter.formatTime12Hour(order.orderTime),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          spacing: 5.0,
                          children: [
                            Icon(Icons.store, size: 20),
                            Expanded(
                              child: FutureBuilder<String>(
                                future: _getSupplierName(order.supplierID),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Color.fromARGB(255, 0, 145, 5),
                      ),
                      onPressed: () async {
                        await _markOrderAsReceived(context, order);
                      },
                    ),
                  ),
                ),
              );
            }, childCount: pendingOrders.length),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const FixeroSubAppBar(
          title: 'Requests & Orders',
          showBackButton: true,
        ),
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: _tabs,
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                children: [
                  const Text("Sort by: "),
                  DropdownButton<String>(
                    value: _tabController.index == 0
                        ? _requestSort
                        : _orderSort,
                    items: const [
                      DropdownMenuItem(value: "Latest", child: Text("Latest")),
                      DropdownMenuItem(value: "Oldest", child: Text("Oldest")),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        if (_tabController.index == 0) {
                          _requestSort = value;
                        } else {
                          _orderSort = value;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPendingRequests(), _buildPendingOrders()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
