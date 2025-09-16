import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final controller = context.read<ItemController>();
    final categories = controller.getCategoriesSync();
    final subcategories = selectedCategory != null
        ? controller.getSubCategoriesSync(selectedCategory!)
        : <String>[];

    return Scaffold(
      appBar: FixeroSubAppBar(title: "Edit Item", showBackButton: false,),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Item Name
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (v) => v!.isEmpty ? "Item Name is required" : null,
              ),

              // Description
              TextFormField(
                controller: _itemDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Description is required"
                    : null,
              ),

              const SizedBox(height: 16),

              // Category Dropdown or TextField
              isNewCategory
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextFormField(
                          initialValue: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'New Category',
                          ),
                          onChanged: (val) => selectedCategory = val,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter a category name';
                            }
                            return null;
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isNewCategory = false;
                              selectedCategory = null;
                              isNewSubcategory = false;
                              selectedSubcategory = null;
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
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
                          setState(() {
                            isNewCategory = true;
                            isNewSubcategory = true;
                            selectedCategory = '';
                            selectedSubcategory = '';
                          });
                        } else {
                          setState(() {
                            selectedCategory = val;
                            isNewSubcategory = false;
                            selectedSubcategory = null;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (_) {
                        if (selectedCategory == null ||
                            selectedCategory!.trim().isEmpty) {
                          return 'Select a category';
                        }
                        return null;
                      },
                    ),

              const SizedBox(height: 16),

              // Subcategory Dropdown or TextField
              if (selectedCategory != null)
                isNewSubcategory
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextFormField(
                            initialValue: selectedSubcategory,
                            decoration: const InputDecoration(
                              labelText: 'New Subcategory',
                            ),
                            onChanged: (val) => selectedSubcategory = val,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter a subcategory name';
                              }
                              return null;
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isNewSubcategory = false;
                                selectedSubcategory = null;
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      )
                    : DropdownButtonFormField<String>(
                        value: selectedSubcategory,
                        items: [
                          ...subcategories.map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          ),
                          const DropdownMenuItem(
                            value: 'add_new',
                            child: Text('Add New'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == 'add_new') {
                            setState(() {
                              isNewSubcategory = true;
                              selectedSubcategory = '';
                            });
                          } else {
                            setState(() => selectedSubcategory = val);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Subcategory',
                        ),
                        validator: (_) {
                          if (selectedSubcategory == null ||
                              selectedSubcategory!.trim().isEmpty) {
                            return 'Select a subcategory';
                          }
                          return null;
                        },
                      ),

              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _itemPriceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Price is required';
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),

              // Unit
              TextFormField(
                controller: _itemUnitController,
                decoration: const InputDecoration(labelText: 'Unit'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Unit is required" : null,
              ),

              // Low Stock Threshold
              TextFormField(
                controller: _lowStockThresholdController,
                decoration: const InputDecoration(
                  labelText: 'Low Stock Threshold',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Low Stock Threshold is required';
                  }
                  final val = int.tryParse(v);
                  if (val == null || val < 1) {
                    return 'Enter a valid number (1 or above)';
                  }
                  return null;
                },
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Discard Changes?'),
                            content: const Text(
                              'Are you sure you want to discard your changes?',
                            ),
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
                      },
                      child: const Text("Discard"),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Save Changes?'),
                            content: const Text(
                              'Are you sure you want to save the changes?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => navigator.pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => navigator.pop(true),
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        final updatedItem = Item(
                          itemId: widget.item.itemId,
                          itemName: _itemNameController.text.trim(),
                          itemDescription: _itemDescriptionController.text
                              .trim(),
                          itemCategory: selectedCategory ?? '',
                          itemSubCategory: selectedSubcategory ?? '',
                          itemPrice:
                              double.tryParse(_itemPriceController.text) ?? 0,
                          stockQuantity: widget.item.stockQuantity,
                          unit: _itemUnitController.text.trim(),
                          lowStockThreshold:
                              int.tryParse(_lowStockThresholdController.text) ??
                              0,
                          imageUrl: widget.item.imageUrl,
                        );

                        try {
                          await controller.updateItem(updatedItem);
                          if (!mounted) return;

                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Item updated successfully!'),
                            ),
                          );

                          navigator.pop();
                        } catch (e) {
                          if (!mounted) return;

                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to update item: $e'),
                            ),
                          );
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
