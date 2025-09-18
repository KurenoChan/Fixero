import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fixero/features/CRM/views/service_feedback_reply_page.dart';

class CustomerFeedbackPage extends StatefulWidget {
  const CustomerFeedbackPage({super.key});

  @override
  State<CustomerFeedbackPage> createState() => _CustomerFeedbackPageState();
}

class _CustomerFeedbackPageState extends State<CustomerFeedbackPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  bool isLoading = true;
  List<Map<String, dynamic>> feedbacks = [];
  List<Map<String, dynamic>> filteredFeedbacks = [];

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

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _markAsSeen(String feedbackId) async {
    try {
      await dbRef
          .child("communications/feedbacks/$feedbackId")
          .update({"seenStatus": "Seen"});
    } catch (e) {
      debugPrint("❌ Failed to update seenStatus for $feedbackId: $e");
    }
  }

  Future<void> _loadFeedbacks() async {
    setState(() => isLoading = true);

    final fbSnap = await dbRef.child("communications/feedbacks").get();

    if (!fbSnap.exists) {
      setState(() {
        isLoading = false;
        feedbacks = [];
        filteredFeedbacks = [];
      });
      return;
    }

    List<Map<String, dynamic>> temp = [];

    for (final child in fbSnap.children) {
      final fbData = Map<String, dynamic>.from(child.value as Map);

      // only show open feedbacks
      final status = (fbData["status"] ?? "").toString().trim().toLowerCase();
      if (status != "open") continue;

      final jobId = fbData["jobID"];
      if (jobId == null || jobId.isEmpty) continue;

      // 🔹 Fetch job record
      final jobSnap = await dbRef.child("jobservices/jobs/$jobId").get();
      if (!jobSnap.exists) continue;
      final jobData = Map<String, dynamic>.from(jobSnap.value as Map);

      // 🔹 Fetch vehicle record
      final plateNo = jobData["plateNo"] ?? "";
      final vehicleSnap = await dbRef.child("vehicles/$plateNo").get();
      final vehicleData =
      vehicleSnap.exists ? Map<String, dynamic>.from(vehicleSnap.value as Map) : {};

      // 🔹 Fetch customer record
      final ownerId = vehicleData["ownerID"] ?? "";
      final custSnap = await dbRef.child("users/customers/$ownerId").get();
      final customerData =
      custSnap.exists ? Map<String, dynamic>.from(custSnap.value as Map) : {};

      // 🔹 Collect combined data
      temp.add({
        "feedbackID": child.key,
        "customerName": customerData["custName"] ?? "Unknown",
        "carModel": vehicleData["model"] ?? "-",
        "serviceType": jobData["jobServiceType"] ?? "-",
        "feedbackType": fbData["feedbackType"] ?? "General",
        "date": fbData["date"] ?? "-",
        "seenStatus": fbData["seenStatus"] ?? "Seen",
        "comment": fbData["comment"] ?? "-",
      });
    }

    // Sort Unseen first
    temp.sort((a, b) {
      if (a["seenStatus"] == "Unseen" && b["seenStatus"] != "Unseen") return -1;
      if (a["seenStatus"] != "Unseen" && b["seenStatus"] == "Unseen") return 1;
      return 0;
    });

    setState(() {
      feedbacks = temp;
    });

    _applyFilters(); // apply filter on load
    setState(() => isLoading = false);
  }

  void _applyFilters() {
    List<Map<String, dynamic>> temp = feedbacks;

    // search filter
    if (searchQuery.isNotEmpty) {
      temp = temp.where((fb) {
        final query = searchQuery.toLowerCase();
        return fb["customerName"].toLowerCase().contains(query) ||
            fb["carModel"].toLowerCase().contains(query) ||
            fb["comment"].toLowerCase().contains(query) ||
            fb["serviceType"].toLowerCase().contains(query);
      }).toList();
    }

    // feedback type filter
    if (selectedFeedbackType != "All") {
      temp = temp.where((fb) => fb["feedbackType"] == selectedFeedbackType).toList();
    }

    // service type filter
    if (selectedServiceType != "All") {
      temp = temp.where((fb) => fb["serviceType"] == selectedServiceType).toList();
    }

    setState(() => filteredFeedbacks = temp);
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
        title: const Text("Customer Feedback"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔎 Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search feedbacks...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
                _applyFilters();
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
                        .map((ft) => DropdownMenuItem(
                      value: ft,
                      child: Text(ft),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedFeedbackType = value!);
                      _applyFilters();
                    },
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
                        .map((st) => DropdownMenuItem(
                      value: st,
                      child: Text(st),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedServiceType = value!);
                      _applyFilters();
                    },
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

          // 📋 List
          Expanded(
            child: filteredFeedbacks.isEmpty
                ? const Center(child: Text("No feedbacks found."))
                : ListView.builder(
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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Service: ${fb['serviceType']}"),
                        Text("Feedback: ${fb['feedbackType']}"),
                        Text("Car: ${fb['carModel']}"),
                        Text("Date: ${fb['date']}"),
                      ],
                    ),
                    trailing: fb["seenStatus"] == "Unseen"
                        ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Unseen",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                        : null,
                    onTap: () async {
                      final feedbackId = fb["feedbackID"];
                      if (feedbackId != null) {
                        await _markAsSeen(feedbackId);
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ServiceFeedbackReplyPage(feedback: fb),
                        ),
                      );

                      _loadFeedbacks(); // refresh after reply
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
