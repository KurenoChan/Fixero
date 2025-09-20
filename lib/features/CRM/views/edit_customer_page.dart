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

    _selectedGender = widget.customer.gender;
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

  // ✅ Save profile logic
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    widget.customer
      ..custName = _nameCtrl.text.trim()
      ..custEmail = _emailCtrl.text.trim()
      ..custTel = _telCtrl.text.trim()
      ..dob = _dobCtrl.text.trim()
      ..gender = _selectedGender ?? "Male"
      ..address1 = _address1Ctrl.text.trim()
      ..address2 = _address2Ctrl.text.trim()
      ..city = _cityCtrl.text.trim()
      ..state = _stateCtrl.text.trim()
      ..postalCode = _postalCtrl.text.trim()
      ..country = _countryCtrl.text.trim();

    await _customerController.updateCustomer(widget.customer);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context, widget.customer);
    }
  }

  // ✅ Ask for confirmation before saving
  Future<void> _confirmSave() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Save"),
        content: const Text("Are you sure you want to save the changes?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _saveProfile();
    }
  }

  // ✅ Reusable styled input decoration
  InputDecoration kInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                )),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information
            _buildSectionCard(
              title: "Personal Information",
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: kInputDecoration("Name", Icons.person),
                  validator: (v) => v!.isEmpty ? "Enter name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: kInputDecoration("Email", Icons.email),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter email";
                    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                    return emailRegex.hasMatch(v) ? null : "Enter valid email";
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telCtrl,
                  decoration: kInputDecoration("Phone", Icons.phone),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter phone number";
                    final phoneRegex = RegExp(r'^\d{10,15}$'); // 10–15 digits
                    return phoneRegex.hasMatch(v) ? null : "Enter valid phone number";
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dobCtrl,
                  decoration: kInputDecoration("Date of Birth", Icons.calendar_today),
                  validator: (v) => v!.isEmpty ? "Enter DOB" : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: kInputDecoration("Gender", Icons.wc),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                  },
                  validator: (v) => v == null || v.isEmpty ? "Select gender" : null,
                ),
              ],
            ),

            // Address Information
            _buildSectionCard(
              title: "Address",
              children: [
                TextFormField(
                  controller: _address1Ctrl,
                  decoration: kInputDecoration("Address Line 1", Icons.home),
                  validator: (v) => v!.isEmpty ? "Enter address line 1" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address2Ctrl,
                  decoration: kInputDecoration("Address Line 2", Icons.home_outlined),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityCtrl,
                  decoration: kInputDecoration("City", Icons.location_city),
                  validator: (v) => v!.isEmpty ? "Enter city" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stateCtrl,
                  decoration: kInputDecoration("State", Icons.map),
                  validator: (v) => v!.isEmpty ? "Enter state" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _postalCtrl,
                  decoration: kInputDecoration("Postal Code", Icons.local_post_office),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter postal code";
                    final postalRegex = RegExp(r'^\d{5}$'); // exactly 5 digits
                    return postalRegex.hasMatch(v) ? null : "Enter valid 5-digit postal code";
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _countryCtrl,
                  decoration: kInputDecoration("Country", Icons.flag),
                  validator: (v) => v!.isEmpty ? "Enter country" : null,
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // ✅ Sticky Save button at bottom with confirmation
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _confirmSave,
            icon: const Icon(Icons.save),
            label: const Text("Save Profile", style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
