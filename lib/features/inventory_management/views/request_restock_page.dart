import 'package:fixero/data/dao/inventory/requested_item_dao.dart';
import 'package:fixero/data/dao/inventory/restock_request_dao.dart';
import 'package:fixero/features/authentication/controllers/manager_controller.dart';
import 'package:fixero/features/inventory_management/controllers/requested_item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restock_request_controller.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:fixero/utils/generators/id_generator.dart';
import 'package:flutter/material.dart';
import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/inventory_management/models/item.dart';
import 'package:provider/provider.dart';

class RequestRestockPage extends StatefulWidget {
  final Item item;

  const RequestRestockPage({super.key, required this.item});

  @override
  State<RequestRestockPage> createState() => _RequestRestockPageState();
}

class _RequestRestockPageState extends State<RequestRestockPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _discard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Request?'),
        content: const Text('Are you sure you want to discard this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Capture synchronous values first
    final managerFuture = ManagerController.getCurrentManager();
    final restockController = context.read<RestockRequestController>();
    final itemController = context.read<RequestedItemController>();

    // Await async work
    final manager = await managerFuture;
    if (manager == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to identify current manager")),
      );
      return;
    }

    final restockRequestId = IDGenerator.generateRestockRequestID();
    final requestedItemId = IDGenerator.generateRequestedItemID();

    debugPrint("\n\nGenerated RestockRequest ID: $restockRequestId");
    debugPrint("Generated RequestedItem ID: $requestedItemId\n\n");

    final restockRequest = RestockRequest(
      requestID: restockRequestId,
      requestDate: Formatter.today(),
      requestTime: Formatter.today(),
      requestBy: manager.id,
    );

    final requestedItem = RequestedItem(
      requestItemID: requestedItemId,
      requestID: restockRequestId,
      itemID: widget.item.itemID,
      quantityRequested: int.parse(_quantityController.text),
      remark: _notesController.text.isEmpty ? null : _notesController.text,
    );

    try {
      // ✅ Save to RTDB
      await RestockRequestDAO().addRequest(restockRequest);
      await RequestedItemDAO().addRequestedItem(requestedItem);

      // ✅ Update provider/controllers
      await restockController.addRequest(restockRequest);
      await itemController.addRequestedItem(requestedItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Restock request has been successfully submitted"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: FixeroSubAppBar(
        title: "Issue Restock Request",
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  Text(
                    'Item Details',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
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
                ],
              ),

              const SizedBox(height: 10.0),

              // 🔹 Item ID
              TextFormField(
                enabled: false,
                initialValue: item.itemID,
                decoration: const InputDecoration(labelText: 'Item ID'),
              ),

              // 🔹 Item Name
              TextFormField(
                enabled: false,
                initialValue: item.itemName,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),

              // 🔹 Description
              TextFormField(
                enabled: false,
                initialValue: item.itemDescription,
                decoration: const InputDecoration(labelText: 'Description'),
              ),

              // 🔹 Category
              TextFormField(
                enabled: false,
                initialValue: item.itemCategory,
                decoration: const InputDecoration(labelText: 'Category'),
              ),

              // 🔹 Subcategory
              TextFormField(
                enabled: false,
                initialValue: item.itemSubCategory,
                decoration: const InputDecoration(labelText: 'Subcategory'),
              ),

              // 🔹 Price
              TextFormField(
                enabled: false,
                initialValue: item.itemPrice.toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Price'),
              ),

              // 🔹 Stock Quantity
              TextFormField(
                enabled: false,
                initialValue: item.stockQuantity.toString(),
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
              ),

              // 🔹 Unit
              TextFormField(
                enabled: false,
                initialValue: item.unit,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),

              // 🔹 Low Stock Threshold
              TextFormField(
                enabled: false,
                initialValue: item.lowStockThreshold.toString(),
                decoration: const InputDecoration(
                  labelText: 'Low Stock Threshold',
                ),
              ),

              const SizedBox(height: 40),

              Column(
                children: [
                  Text(
                    'Request Details',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
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
                ],
              ),

              const SizedBox(height: 10.0),

              // 🔹 Quantity to Request
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Request Quantity (${item.unit})",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter a quantity";
                  }
                  final val = int.tryParse(v);
                  if (val == null || val <= 0) {
                    return "Enter a valid positive number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 🔹 Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Remarks (Optional)",
                ),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Discard Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.inverseSurface.withAlpha(50),
                      ),
                      onPressed: _discard,
                      child: const Text("Discard"),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Submit Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Submit"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
