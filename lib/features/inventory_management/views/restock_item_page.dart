import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/authentication/controllers/manager_controller.dart';
import 'package:fixero/features/authentication/models/manager.dart';
import 'package:fixero/features/inventory_management/controllers/order_controller.dart';
import 'package:fixero/features/inventory_management/controllers/requested_item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restock_request_controller.dart';
import 'package:fixero/features/inventory_management/models/order.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:fixero/features/inventory_management/models/restock_request.dart';
import 'package:fixero/utils/generators/id_generator.dart';
import 'package:flutter/material.dart';
import 'package:fixero/features/inventory_management/controllers/supplier_controller.dart';
import 'package:fixero/features/inventory_management/models/item.dart';
import 'package:fixero/features/inventory_management/models/supplier.dart';
import 'package:provider/provider.dart';

class RestockItemPage extends StatefulWidget {
  final Item item;

  const RestockItemPage({super.key, required this.item});

  @override
  State<RestockItemPage> createState() => _RestockItemPageState();
}

class _RestockItemPageState extends State<RestockItemPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  Manager? currentManager;

  // Supplier
  List<Supplier> _supplierList = [];
  bool _isLoadingSuppliers = true;
  Supplier? _selectedSupplier;

  // Form keys
  final _formKeys = [
    GlobalKey<FormState>(), // Step 1
    GlobalKey<FormState>(), // Step 2
    GlobalKey<FormState>(), // Step 3
  ];

  // Controllers
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Defer supplier loading to after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuppliers();
    });
  }

  final managerFuture = ManagerController.getCurrentManager();

  Future<void> _loadSuppliers() async {
    setState(() => _isLoadingSuppliers = true);

    final controller = context.read<SupplierController>();
    await controller.loadSuppliers();

    if (!mounted) return; // safety check
    setState(() {
      _supplierList = controller.suppliers;
      _isLoadingSuppliers = false;
    });
  }

  Supplier? getSupplierById(String id) {
    try {
      return _supplierList.firstWhere((s) => s.supplierID == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _submit();
      }
    }
  }

  void _backStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _discard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Discard Restock Order?"),
        content: const Text("Are you sure you want to discard this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Close page
            },
            child: const Text("Discard"),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    // Get current manager
    final manager = await ManagerController.getCurrentManager();
    if (!mounted) return; // ✅ Guard against disposed state
    if (manager == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Manager not found")));
      return;
    }

    try {
      // Generate IDs
      final restockRequestId = IDGenerator.generateRestockRequestID();
      final requestedItemId = IDGenerator.generateRequestedItemID();

      // 1️⃣ CREATE ORDER
      final supplierId =
          _selectedSupplier?.supplierID ?? _supplierList.first.supplierID;

      final order = Order(
        orderNo: IDGenerator.generateOrderNo(),
        orderDate: DateTime.now(),
        supplierID: supplierId,
      );
      await context.read<OrderController>().addOrder(order);
      if (!mounted) return;

      final createdOrder = context.read<OrderController>().orders.last;
      final createdOrderNo = createdOrder.orderNo;

      // 2️⃣ CREATE RESTOCK REQUEST (auto-approved)
      final restockRequest = RestockRequest(
        requestId: restockRequestId,
        orderNo: createdOrderNo,
        requestBy: manager.id,
        approvedBy: manager.id,
        approvedDate: DateTime.now(),
        status: "Approved",
        requestDateTime: DateTime.now(),
      );
      await context.read<RestockRequestController>().createRequest(
        restockRequest,
      );
      if (!mounted) return;

      // 3️⃣ CREATE REQUESTED ITEM
      final requestedItem = RequestedItem(
        requestItemId: requestedItemId,
        requestId: restockRequestId,
        itemId: widget.item.itemId,
        quantityRequested: int.parse(_quantityController.text),
        remark: _notesController.text.isEmpty ? null : _notesController.text,
        status: "Pending",
      );
      await context.read<RequestedItemController>().createItem(requestedItem);
      if (!mounted) return;

      // ✅ Debug logs
      print("\n\nGenerated Order No: $createdOrderNo");
      print("Generated RestockRequest ID: $restockRequestId");
      print("Generated RequestedItem ID: $requestedItemId\n\n");

      // ✅ Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restock order submitted successfully")),
      );

      // Clear form
      _quantityController.clear();
      _notesController.clear();
      setState(() => _selectedSupplier = null);

      Navigator.pop(context);
    } catch (e) {
      print(e);
      // if (!mounted) return;
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildStepIndicator() {
    final steps = ["Item Details", "Request Details", "Order Details"];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isEven) {
          final index = i ~/ 2;
          final isActive = _currentStep == index;
          final isCompleted = _currentStep > index;
          return Expanded(
            child: Column(
              children: [
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive || isCompleted ? Colors.blue : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.blue : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive || isCompleted
                          ? Colors.blue
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: isActive ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        } else {
          final leftIndex = (i - 1) ~/ 2;
          final isCompleted = _currentStep > leftIndex;
          return Container(
            width: 40,
            height: 2,
            color: isCompleted ? Colors.blue : Colors.grey.shade300,
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixeroSubAppBar(title: "Restock Item", showBackButton: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildStepIndicator(), // ✅ Step indicator shown
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _itemDetailsForm(),
                _requestDetailsForm(),
                _orderDetailsForm(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Cancel button only on Step 0
            if (_currentStep == 0)
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
            if (_currentStep == 0) const SizedBox(width: 16),

            // Back button (for steps > 0)
            if (_currentStep > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: _backStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                  ),
                  child: const Text("Back"),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),

            // Next / Submit button
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(_currentStep == 2 ? "Submit" : "Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[0],
        child: ListView(
          children: [
            Text(
              "Step 1: Confirm Item Details",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _readOnlyField("Item ID", widget.item.itemId),
            _readOnlyField("Name", widget.item.itemName),
            _readOnlyField("Description", widget.item.itemDescription),
            _readOnlyField("Category", widget.item.itemCategory),
            _readOnlyField("Subcategory", widget.item.itemSubCategory),
            _readOnlyField(
              "Stock Quantity",
              widget.item.stockQuantity.toString(),
            ),
            _readOnlyField("Unit", widget.item.unit),
          ],
        ),
      ),
    );
  }

  Widget _requestDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[1],
        child: ListView(
          children: [
            Text(
              "Step 2: Request Details",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity (${widget.item.unit})",
              ),
              validator: (val) {
                final n = int.tryParse(val ?? "");
                if (n == null || n <= 0) return "Enter a valid quantity";
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Remarks (Optional)",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[2],
        child: _isLoadingSuppliers
            ? const Center(child: CircularProgressIndicator())
            : _supplierList.isEmpty
            ? const Center(child: Text("No suppliers available"))
            : DropdownButtonFormField<Supplier>(
                value: _selectedSupplier,
                items: _supplierList
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.supplierName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedSupplier = v),
                validator: (val) => val == null ? "Select a supplier" : null,
                decoration: const InputDecoration(labelText: "Supplier"),
              ),
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
