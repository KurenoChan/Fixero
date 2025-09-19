import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../controllers/customer_controller.dart';
import '../models/vehicle_model.dart';
import '../controllers/vehicle_controller.dart';
import '../../../common/widgets/bars/fixero_sub_appbar.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';

class CustomerProfilePage extends StatefulWidget {
  final String customerId;
  final Map<String, dynamic>? customerData; // nullable now

  const CustomerProfilePage({
    super.key,
    required this.customerId,
    this.customerData,
  });

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final VehicleController _vehicleController = VehicleController();
  final CustomerController _customerController = CustomerController();

  Customer? customer;
  List<Vehicle> vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 🔹 1) If no customerData passed in → fetch from CustomerController
    if (widget.customerData == null || widget.customerData!.isEmpty) {
      final fetched =
      await _customerController.fetchCustomerById(widget.customerId);
      if (fetched != null) {
        customer = fetched;
      }
    } else {
      // 🔹 Construct Customer from provided map
      customer = Customer.fromMap(widget.customerId, widget.customerData!);
    }

    // 🔹 2) Load vehicles
    final fetchedVehicles =
    _vehicleController.fetchVehiclesByOwner(widget.customerId);

    setState(() {
      vehicles = fetchedVehicles;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (customer == null) {
      return const Scaffold(
        body: Center(child: Text("Customer not found")),
      );
    }

    final theme = Theme.of(context);
    final isFemale = customer!.gender.toLowerCase() == 'female';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: FixeroSubAppBar(
        title: customer!.custName,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Profile Header
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        isFemale
                            ? "assets/icons/avatar/female_avatar.png"
                            : "assets/icons/avatar/male_avatar.png",
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      customer!.custName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      customer!.custEmail,
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Personal Info
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _infoTile(Icons.person, "Gender", customer!.gender),
                  _divider(),
                  _infoTile(Icons.cake, "Date of Birth", customer!.dob),
                  _divider(),
                  _infoTile(Icons.phone, "Phone", customer!.custTel),
                  _divider(),
                  _infoTile(Icons.email, "Email", customer!.custEmail),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Address
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text("Address",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "${customer!.address1}, ${customer!.address2}, "
                      "${customer!.city}, ${customer!.state}, "
                      "${customer!.postalCode}, ${customer!.country}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Vehicles
            Text("Car(s)",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            const SizedBox(height: 10),
            if (vehicles.isEmpty)
              const Text("No vehicles found for this customer",
                  style: TextStyle(color: Colors.grey))
            else
              Column(
                children: vehicles.map((v) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                        child: const Icon(Icons.directions_car,
                            color: Colors.redAccent),
                      ),
                      title: Text(
                        v.plateNumber,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle:
                      Text("${v.manufacturer} ${v.model} (${v.year})"),
                      trailing: Text(v.color,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const FixeroBottomAppBar(),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(value.isNotEmpty ? value : "Not provided"),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 0.8);
  }
}
