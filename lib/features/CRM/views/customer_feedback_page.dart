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

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => isLoading = true);

    final fbSnap = await dbRef.child("communications/feedbacks").get();

    if (!fbSnap.exists) {
      setState(() {
        isLoading = false;
        feedbacks = [];
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
      isLoading = false;
    });
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
          : feedbacks.isEmpty
          ? const Center(child: Text("No feedbacks found."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: feedbacks.length,
        itemBuilder: (context, index) {
          final fb = feedbacks[index];
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
    );
  }
}
