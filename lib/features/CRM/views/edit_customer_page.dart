import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../controllers/customer_controller.dart';

class EditCustomerPage extends StatefulWidget {
  final Customer customer;

  const EditCustomerPage({super.key, required this.customer});

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _address1Ctrl;
  late TextEditingController _address2Ctrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _postalCtrl;
  late TextEditingController _countryCtrl;

  String? _selectedGender;

  final CustomerController _customerController = CustomerController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer.custName);
    _emailCtrl = TextEditingController(text: widget.customer.custEmail);
    _telCtrl = TextEditingController(text: widget.customer.custTel);
    _dobCtrl = TextEditingController(text: widget.customer.dob);
    _address1Ctrl = TextEditingController(text: widget.customer.address1);
    _address2Ctrl = TextEditingController(text: widget.customer.address2);
    _cityCtrl = TextEditingController(text: widget.customer.city);
    _stateCtrl = TextEditingController(text: widget.customer.state);
    _postalCtrl = TextEditingController(text: widget.customer.postalCode);
    _countryCtrl = TextEditingController(text: widget.customer.country);

    _selectedGender = widget.customer.gender; // set initial gender
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _dobCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    widget.customer.custName = _nameCtrl.text.trim();
    widget.customer.custEmail = _emailCtrl.text.trim();
    widget.customer.custTel = _telCtrl.text.trim();
    widget.customer.dob = _dobCtrl.text.trim();
    widget.customer.gender = _selectedGender ?? "Male";
    widget.customer.address1 = _address1Ctrl.text.trim();
    widget.customer.address2 = _address2Ctrl.text.trim();
    widget.customer.city = _cityCtrl.text.trim();
    widget.customer.state = _stateCtrl.text.trim();
    widget.customer.postalCode = _postalCtrl.text.trim();
    widget.customer.country = _countryCtrl.text.trim();

    await _customerController.updateCustomer(widget.customer);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context, widget.customer); // ✅ return updated customer
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Customer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) =>
                v!.isNotEmpty && v.contains("@") ? null : "Enter valid email",
              ),
              TextFormField(
                controller: _telCtrl,
                decoration: const InputDecoration(labelText: "Phone"),
                validator: (v) => v!.isEmpty ? "Enter phone number" : null,
              ),
              TextFormField(
                controller: _dobCtrl,
                decoration: const InputDecoration(labelText: "Date of Birth"),
                validator: (v) => v!.isEmpty ? "Enter DOB" : null,
              ),

              // 🔹 Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: "Gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
                validator: (v) => v == null || v.isEmpty ? "Select gender" : null,
              ),

              const SizedBox(height: 20),
              const Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),

              TextFormField(
                controller: _address1Ctrl,
                decoration: const InputDecoration(labelText: "Address Line 1"),
                validator: (v) => v!.isEmpty ? "Enter address line 1" : null,
              ),
              TextFormField(
                controller: _address2Ctrl,
                decoration: const InputDecoration(labelText: "Address Line 2"),
                validator: (v) => v!.isEmpty ? "Enter address line 2" : null,
              ),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: "City"),
                validator: (v) => v!.isEmpty ? "Enter city" : null,
              ),
              TextFormField(
                controller: _stateCtrl,
                decoration: const InputDecoration(labelText: "State"),
                validator: (v) => v!.isEmpty ? "Enter state" : null,
              ),
              TextFormField(
                controller: _postalCtrl,
                decoration: const InputDecoration(labelText: "Postal Code"),
                validator: (v) => v!.isEmpty ? "Enter postal code" : null,
              ),
              TextFormField(
                controller: _countryCtrl,
                decoration: const InputDecoration(labelText: "Country"),
                validator: (v) => v!.isEmpty ? "Enter country" : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
