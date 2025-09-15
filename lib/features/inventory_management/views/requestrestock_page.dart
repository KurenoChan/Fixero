import 'package:flutter/material.dart';
import 'package:fixero/common/widgets/bars/fixero_subappbar.dart';
import 'package:fixero/features/inventory_management/models/item_model.dart';

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // may need controller, dao, repo, and model class to add the request to RTDB

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Restock request submitted for ${widget.item.itemName}"),
      ),
    );
    Navigator.pop(context);
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
                initialValue: item.itemId,
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
