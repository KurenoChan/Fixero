import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CustomerDirectoryPage extends StatelessWidget {
  const CustomerDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference ref =
    FirebaseDatabase.instance.ref().child("users/customers");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Directory"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No customers found"));
          }

          final data =
          Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          final customerKeys = data.keys.toList();

          return ListView.builder(
            itemCount: customerKeys.length,
            itemBuilder: (context, index) {
              final key = customerKeys[index];
              final customer =
              Map<String, dynamic>.from(data[key] as Map<dynamic, dynamic>);

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(customer['custName'] ?? 'No Name'),
                subtitle: Text(customer['custTel'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerProfilePage(
                        customerId: key,
                        customerData: customer,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CustomerProfilePage extends StatelessWidget {
  final String customerId;
  final Map<String, dynamic> customerData;

  const CustomerProfilePage({
    super.key,
    required this.customerId,
    required this.customerData,
  });

  @override
  Widget build(BuildContext context) {
    final fullAddress =
        "${customerData['address1'] ?? ''}, ${customerData['address2'] ?? ''}, ${customerData['city'] ?? ''}, "
        "${customerData['state'] ?? ''}, ${customerData['postalCode'] ?? ''}, ${customerData['country'] ?? ''}";

    return Scaffold(
      appBar: AppBar(title: Text(customerData['custName'] ?? 'Customer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 20),
            Text("Name: ${customerData['custName'] ?? ''}",
                style: const TextStyle(fontSize: 18)),
            Text("Phone: ${customerData['custTel'] ?? ''}",
                style: const TextStyle(fontSize: 18)),
            Text("Email: ${customerData['custEmail'] ?? ''}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text("Address:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(fullAddress, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
