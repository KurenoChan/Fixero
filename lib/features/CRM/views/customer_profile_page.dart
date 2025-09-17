import 'package:flutter/material.dart';

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
        "${customerData['address1'] ?? ''}, ${customerData['address2'] ?? ''}, "
        "${customerData['city'] ?? ''}, ${customerData['state'] ?? ''}, "
        "${customerData['postalCode'] ?? ''}, ${customerData['country'] ?? ''}";

    return Scaffold(
      appBar: AppBar(
        title: Text(customerData['custName'] ?? 'Customer Profile'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    customerData['custName'] ?? '',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    customerData['custEmail'] ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Info section
            const Text("Contact Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: Text(customerData['custTel'] ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: Text(customerData['custEmail'] ?? ''),
            ),
            const SizedBox(height: 20),

            const Text("Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(fullAddress, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
