import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'customer_profile_page.dart';

class CustomerDirectoryPage extends StatefulWidget {
  const CustomerDirectoryPage({super.key});

  @override
  State<CustomerDirectoryPage> createState() => _CustomerDirectoryPageState();
}

class _CustomerDirectoryPageState extends State<CustomerDirectoryPage> {
  final DatabaseReference ref =
  FirebaseDatabase.instance.ref().child("users/customers");
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          "Customer Directory",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: "Search by name, phone, or email",
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // 🔹 Customer List
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: ref.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No customers found"));
                }

                final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);

                // 🔍 Filter (name, phone, email)
                final filtered = data.entries.where((e) {
                  final cust =
                  Map<String, dynamic>.from(e.value as Map<dynamic, dynamic>);
                  final name = (cust['custName'] ?? "").toString().toLowerCase();
                  final tel = (cust['custTel'] ?? "").toString().toLowerCase();
                  final email = (cust['custEmail'] ?? "").toString().toLowerCase();

                  return name.contains(searchQuery) ||
                      tel.contains(searchQuery) ||
                      email.contains(searchQuery);
                }).toList();

                // 🔠 Sort alphabetically by name
                filtered.sort((a, b) {
                  final nameA =
                  (a.value['custName'] ?? "").toString().toLowerCase();
                  final nameB =
                  (b.value['custName'] ?? "").toString().toLowerCase();
                  return nameA.compareTo(nameB);
                });

                if (filtered.isEmpty) {
                  return const Center(child: Text("No matching customers found"));
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final key = filtered[index].key;
                    final customer =
                    Map<String, dynamic>.from(filtered[index].value);

                    final gender =
                    (customer['gender'] ?? '').toString().toLowerCase();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: gender == 'female'
                              ? Colors.pink.withOpacity(0.2)
                              : theme.primaryColor.withOpacity(0.15),
                          child: Icon(
                            gender == 'female' ? Icons.female : Icons.male,
                            size: 30,
                            color: gender == 'female'
                                ? Colors.pink
                                : Colors.blue,
                          ),
                        ),
                        title: RichText(
                          text: TextSpan(
                            children: _highlightMatch(
                              customer['custName'] ?? 'No Name',
                              searchQuery,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          customer['custTel'] ?? '',
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.grey),
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Highlight search matches
  List<TextSpan> _highlightMatch(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);
    if (startIndex == -1) return [TextSpan(text: text)];

    return [
      TextSpan(text: text.substring(0, startIndex)),
      TextSpan(
        text: text.substring(startIndex, startIndex + query.length),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
      TextSpan(text: text.substring(startIndex + query.length)),
    ];
  }
}
