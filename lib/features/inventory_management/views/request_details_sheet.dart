import 'package:fixero/data/dao/inventory/requested_item_dao.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/features/authentication/controllers/manager_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restock_request_controller.dart';
import 'package:fixero/features/inventory_management/views/create_order_sheet.dart';
import 'package:flutter/material.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:provider/provider.dart';

class RequestDetailsSheet extends StatelessWidget {
  final RestockRequest request;
  final bool showApproveButton;

  const RequestDetailsSheet({
    super.key,
    required this.request,
    this.showApproveButton = true,
  });

  Future<void> _rejectRequest(BuildContext context) async {
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
      final requestedItems = await itemDAO.getItemsByRequestId(
        request.requestId,
      );

      for (final item in requestedItems) {
        final updatedItem = item.copyWith(
          status: "Not Processed",
          remark: remark.isNotEmpty ? remark : "Request rejected",
        );
        await itemDAO.updateRequestedItem(updatedItem);
      }

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close sheet

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request rejected successfully.")),
      );
    }
  }

  Future<void> _approveRequest(BuildContext context) async {
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
      Navigator.of(context).pop(); // close sheet

      // ✅ Open the CreateOrderSheet as a bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CreateOrderSheet(approvedRequests: [request]),
      );
      // Call the create order bottom sheet (will do in another file)
      // Select the supplier from dropdown, below it we have all the approved requests just now
      // Only when they select the supplier, then the Create Order button is enabled, click on it and trigger confirmation
      // Can also have discard, so both button display confirmation dialog

      // // ✅ Await the async call to get manager
      // final manager = await ManagerController.getCurrentManager();

      // if (manager == null) {
      //   if (!context.mounted) return;
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Failed to fetch manager info.")),
      //   );
      //   return;
      // }

      // if (!context.mounted) return;
      // await context.read<RestockRequestController>().approveRequest(
      //   request,
      //   manager.id,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemController = context.read<ItemController>();

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
          child: FutureBuilder(
            future: Future.wait([
              RequestedItemDAO().getItemsByRequestId(request.requestId),
              ManagerRepository().getManager(request.requestBy),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final requestedItems = snapshot.data![0] as List<RequestedItem>;
              final manager = snapshot.data![1];

              return Column(
                children: [
                  // Top bar
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
                          "Request Details",
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

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                              request.requestId,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Date & Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(request.requestDate),
                              const SizedBox(width: 10),
                              Text(request.requestTime),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Requested by
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary.withAlpha(70),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      manager?.profileImgUrl != null
                                      ? NetworkImage(manager.profileImgUrl)
                                      : null,
                                  child: manager?.profileImgUrl == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  manager?.name ?? "Unknown",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            "Items",
                            style: TextStyle(
                              fontSize: Theme.of(
                                context,
                              ).textTheme.titleLarge?.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),

                          // Items table wrapped in a fixed height container
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                dataRowMaxHeight: double.infinity,
                                columnSpacing: 10,
                                columns: const [
                                  DataColumn(label: Text("Image")),
                                  DataColumn(label: Text("Name")),
                                  DataColumn(label: Text("Quantity")),
                                  DataColumn(label: Text("Remark")),
                                ],
                                rows: requestedItems.map((item) {
                                  final actualItem = itemController.getItemById(
                                    item.itemID,
                                  );
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          width: 50,
                                          height: 50,
                                          child: actualItem != null
                                              ? Image.network(
                                                  actualItem.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                )
                                              : const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 70,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            child: Text(
                                              actualItem?.itemName ?? "Unknown",
                                              softWrap: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 40,
                                          ),
                                          child: Text(
                                            item.quantityRequested.toString(),
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 110,
                                          ),
                                          child: Text(
                                            item.remark ?? "",
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          if (showApproveButton)
                            // Bottom action buttons
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
                                      await _rejectRequest(context);
                                    },
                                    icon: const Icon(Icons.close),
                                    label: const Text("Reject"),
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
                                      await _approveRequest(context);
                                    },
                                    icon: const Icon(Icons.check),
                                    label: const Text("Approve"),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
