import 'package:fixero/common/widgets/bars/fixero_subappbar.dart';
import 'package:fixero/features/inventory_management/controllers/inventory_controller.dart';
import 'package:fixero/features/inventory_management/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditItemPage extends StatefulWidget {
  final Item item;
  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _itemNameController;
  late TextEditingController _itemDescriptionController;
  late TextEditingController _itemPriceController;
  late TextEditingController _itemUnitController;
  late TextEditingController _lowStockThresholdController;
  bool isNewCategory = false;
  bool isNewSubcategory = false;

  String? selectedCategory;
  String? selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.item.itemName);
    _itemDescriptionController = TextEditingController(
      text: widget.item.itemDescription,
    );
    _itemPriceController = TextEditingController(
      text: widget.item.itemPrice.toString(),
    );
    _itemUnitController = TextEditingController(text: widget.item.unit);
    _lowStockThresholdController = TextEditingController(
      text: widget.item.lowStockThreshold.toString(),
    );

    selectedCategory = widget.item.itemCategory;
    selectedSubcategory = widget.item.itemSubCategory;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemPriceController.dispose();
    _itemUnitController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<InventoryController>(context, listen: false);

    return Scaffold(
      appBar: FixeroSubAppBar(title: "Edit Item"),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _itemDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),

              // 🔹 Category dropdown or text field
              FutureBuilder<List<String>>(
                future: controller.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final categories = snapshot.data!;
                  return isNewCategory
                      ? TextFormField(
                          controller: TextEditingController(
                            text: selectedCategory,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'New Category',
                          ),
                          onChanged: (val) => selectedCategory = val,
                        )
                      : DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: [
                            ...categories.map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            ),
                            const DropdownMenuItem(
                              value: 'add_new',
                              child: Text('Add New'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == 'add_new') {
                              setState(() => isNewCategory = true);
                            } else {
                              setState(() {
                                selectedCategory = val;
                                isNewSubcategory = false;
                                selectedSubcategory = null;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                        );
                },
              ),
              const SizedBox(height: 16),

              // 🔹 Subcategory dropdown or text field
              if (selectedCategory != null)
                FutureBuilder<List<String>>(
                  future: controller.getSubCategories(selectedCategory!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final subcategories = snapshot.data!;
                    return isNewSubcategory
                        ? TextFormField(
                            controller: TextEditingController(
                              text: selectedSubcategory,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'New Subcategory',
                            ),
                            onChanged: (val) => selectedSubcategory = val,
                          )
                        : DropdownButtonFormField<String>(
                            value: selectedSubcategory,
                            items: [
                              ...subcategories.map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              ),
                              const DropdownMenuItem(
                                value: 'add_new',
                                child: Text('Add New'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == 'add_new') {
                                setState(() => isNewSubcategory = true);
                              } else {
                                setState(() => selectedSubcategory = val);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Subcategory',
                            ),
                          );
                  },
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _itemPriceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _itemUnitController,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              TextFormField(
                controller: _lowStockThresholdController,
                decoration: const InputDecoration(
                  labelText: 'Low Stock Threshold',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 🔹 Call controller to update the item here
                  }
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
