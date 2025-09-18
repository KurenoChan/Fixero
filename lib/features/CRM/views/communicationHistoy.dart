import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CommunicationHistoryPage extends StatefulWidget {
  const CommunicationHistoryPage({super.key});

  @override
  State<CommunicationHistoryPage> createState() => _CommunicationHistoryPageState();
}

class _CommunicationHistoryPageState extends State<CommunicationHistoryPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  // Filters
  String searchQuery = "";
  String selectedFeedbackType = "All";
  String selectedServiceType = "All";

  final List<String> feedbackTypes = ["All", "Positive", "Complaint", "Suggestion"];
  final List<String> serviceTypes = [
    "All",
    "Vehicle Safety Check",
    "Car Repair",
    "Battery Repair",
    "Fuel Tank Maintenance",
    "Tire Repair"
  ];

  List<Map<String, dynamic>> _processData(DataSnapshot fbSnap) {
    List<Map<String, dynamic>> temp = [];

    for (final child in fbSnap.children) {
      final fbData = Map<String, dynamic>.from(child.value as Map);

      // ✅ Only Closed feedbacks
      final status = (fbData["status"] ?? "").toString().trim().toLowerCase();
      if (status != "closed") continue;

      temp.add({
        "feedbackID": child.key,
        "customerName": fbData["customerName"] ?? "Unknown",
        "carModel": fbData["carModel"] ?? "-",
        "serviceType": fbData["serviceType"] ?? "-",
        "feedbackType": fbData["feedbackType"] ?? "General",
        "date": fbData["date"] ?? "-",
        "seenStatus": fbData["seenStatus"] ?? "Seen",
        "comment": fbData["comment"] ?? "-",
      });
    }

    // Sort latest first
    temp.sort((a, b) {
      final dateA = DateTime.tryParse(a["date"] ?? "") ?? DateTime(1970);
      final dateB = DateTime.tryParse(b["date"] ?? "") ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    return temp;
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> feedbacks) {
    List<Map<String, dynamic>> temp = feedbacks;

    // search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      temp = temp.where((fb) {
        return (fb["customerName"] ?? "").toString().toLowerCase().contains(query) ||
            (fb["carModel"] ?? "").toString().toLowerCase().contains(query) ||
            (fb["comment"] ?? "").toString().toLowerCase().contains(query) ||
            (fb["serviceType"] ?? "").toString().toLowerCase().contains(query);
      }).toList();
    }

    // feedback type filter
    if (selectedFeedbackType != "All") {
      temp = temp.where((fb) => (fb["feedbackType"] ?? "") == selectedFeedbackType).toList();
    }

    // service type filter
    if (selectedServiceType != "All") {
      temp = temp.where((fb) => (fb["serviceType"] ?? "") == selectedServiceType).toList();
    }

    return temp;
  }

  String _getServiceIcon(String serviceType) {
    if (serviceType.isEmpty) {
      return "assets/icons/services_Icon/default.png"; // fallback
    }
    final fileName = serviceType
        .toLowerCase()
        .replaceAll(" ", "_")
        .replaceAll("-", "_")
        .replaceAll("/", "_");
    return "assets/icons/services_Icon/$fileName.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Communication History"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔎 Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search history...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),

          // 🔽 Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFeedbackType,
                    items: feedbackTypes
                        .map((ft) => DropdownMenuItem(value: ft, child: Text(ft)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedFeedbackType = value!),
                    decoration: const InputDecoration(
                      labelText: "Feedback Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedServiceType,
                    items: serviceTypes
                        .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedServiceType = value!),
                    decoration: const InputDecoration(
                      labelText: "Service Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 📋 List (real-time)
          Expanded(
            child: StreamBuilder(
              stream: dbRef.child("communications/feedbacks").onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || (snapshot.data! as DatabaseEvent).snapshot.value == null) {
                  return const Center(child: Text("No closed feedbacks found."));
                }

                final fbSnap = (snapshot.data! as DatabaseEvent).snapshot;
                final feedbacks = _processData(fbSnap);
                final filteredFeedbacks = _applyFilters(feedbacks);

                if (filteredFeedbacks.isEmpty) {
                  return const Center(child: Text("No records match your filter/search."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredFeedbacks.length,
                  itemBuilder: (context, index) {
                    final fb = filteredFeedbacks[index];
                    final iconPath = _getServiceIcon(fb["serviceType"]);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: Image.asset(iconPath, fit: BoxFit.contain),
                        ),
                        title: Text(
                          fb["customerName"],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Service: ${fb['serviceType']}"),
                            Text("Feedback: ${fb['feedbackType']}"),
                            Text("Car: ${fb['carModel']}"),
                            Text("Date: ${fb['date']}"),
                            Text("Comment: ${fb['comment']}"),
                          ],
                        ),
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
}
