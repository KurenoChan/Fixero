import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../controllers/customer_controller.dart';
import '../models/vehicle_model.dart';
import '../controllers/vehicle_controller.dart';

class CustomerProfilePage extends StatefulWidget {
  final String customerId;
  final Map<String, dynamic> customerData;

  const CustomerProfilePage({
    super.key,
    required this.customerId,
    required this.customerData,
  });

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final VehicleController _vehicleController = VehicleController();
  List<Vehicle> vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final fetched = await _vehicleController.fetchVehiclesByOwner(widget.customerId);
    setState(() {
      vehicles = fetched;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customer = widget.customerData;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          customer['custName'] ?? 'Customer Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Profile Header
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: (customer['gender']?.toLowerCase() == 'female')
                          ? Colors.pink.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      child: Icon(
                        (customer['gender']?.toLowerCase() == 'female')
                            ? Icons.female
                            : Icons.male,
                        size: 60,
                        color: (customer['gender']?.toLowerCase() == 'female')
                            ? Colors.pink
                            : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      customer['custName'] ?? '',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      customer['custEmail'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Personal Info
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _infoTile(Icons.person, "Gender", customer['gender'] ?? ''),
                  _divider(),
                  _infoTile(Icons.cake, "Date of Birth", customer['dob'] ?? ''),
                  _divider(),
                  _infoTile(Icons.phone, "Phone", customer['custTel'] ?? ''),
                  _divider(),
                  _infoTile(Icons.email, "Email", customer['custEmail'] ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Address
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text("Address",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "${customer['address1'] ?? ''}, ${customer['address2'] ?? ''}, "
                      "${customer['city'] ?? ''}, ${customer['state'] ?? ''}, "
                      "${customer['postalCode'] ?? ''}, ${customer['country'] ?? ''}",
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
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (vehicles.isEmpty)
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
                        backgroundColor: Colors.redAccent.withOpacity(0.2),
                        child: const Icon(Icons.directions_car,
                            color: Colors.redAccent),
                      ),
                      title: Text(
                        v.plateNumber,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text("${v.manufacturer} ${v.model} (${v.year})"),
                      trailing: Text(v.color,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
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
