import 'package:flutter/material.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../../../common/widgets/bars/fixero_sub_appbar.dart';
import '../controllers/customer_controller.dart';
import '../controllers/vehicle_controller.dart';
import 'customer_profile_page.dart';

class CustomerDirectoryPage extends StatefulWidget {
  const CustomerDirectoryPage({super.key});

  @override
  State<CustomerDirectoryPage> createState() => _CustomerDirectoryPageState();
}

class _CustomerDirectoryPageState extends State<CustomerDirectoryPage> {
  final CustomerController customerController = CustomerController();
  final VehicleController vehicleController = VehicleController();
  String searchQuery = "";
  String sortOption = "A-Z"; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const FixeroSubAppBar(
        title: "Customer Directory",
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 🔍 Search + Sort combined
          // 🔍 Search + Sort combined
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Search field (clean look, no background, centered)
                  Expanded(
                    child: TextField(
                      onChanged: (val) =>
                          setState(() => searchQuery = val.toLowerCase()),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: Colors.blue),
                        hintText: "Search name, phone, or email",
                        border: InputBorder.none,          // remove underline
                        enabledBorder: InputBorder.none,   // remove when not focused
                        focusedBorder: InputBorder.none,   // remove when focused
                        isCollapsed: true,                 // tighter padding
                        filled: false,                     // no background fill
                      ),
                    ),
                  ),


                  // ↕️ Sort dropdown styled like the other page
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort, color: Colors.blue),
                    onSelected: (val) =>
                        setState(() => sortOption = val),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "A-Z", child: Text("A → Z")),
                      PopupMenuItem(value: "Z-A", child: Text("Z → A")),
                    ],
                  ),
                ],
              ),
            ),
          ),


          // 🔹 Customer list
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: customerController,
              builder: (context, _, __) {
                var customers = customerController.allCustomers;

                // 🔍 Search filter
                if (searchQuery.isNotEmpty) {
                  customers = customers
                      .where((c) =>
                  c.custName.toLowerCase().contains(searchQuery) ||
                      c.custTel.toLowerCase().contains(searchQuery) ||
                      c.custEmail.toLowerCase().contains(searchQuery))
                      .toList();
                }

                // 🔠 Sort
                customers.sort((a, b) {
                  if (sortOption == "A-Z") {
                    return a.custName
                        .toLowerCase()
                        .compareTo(b.custName.toLowerCase());
                  } else {
                    return b.custName
                        .toLowerCase()
                        .compareTo(a.custName.toLowerCase());
                  }
                });

                if (customers.isEmpty) {
                  return const Center(child: Text("No customers found"));
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: customers.length,
                  itemBuilder: (_, i) {
                    final c = customers[i];
                    final isFemale = c.gender.toLowerCase() == "female";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage(
                            isFemale
                                ? "assets/icons/avatar/female_avatar.png"
                                : "assets/icons/avatar/male_avatar.png",
                          ),

                        ),
                        title: Text(c.custName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        subtitle: Text(c.custTel),
                        trailing:
                        const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerProfilePage(
                                  customerId: c.custID,
                                  customerData: c.toMap(),
                                ),
                              ),
                            );
                          },

                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FixeroBottomAppBar(),
    );
  }
}
