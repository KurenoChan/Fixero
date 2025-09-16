import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../common/widgets/bars/fixero_mainappbar.dart';
import 'service_feedback_detail_page.dart';

class CommunicationHistoryPage extends StatefulWidget {
  const CommunicationHistoryPage({super.key});

  @override
  State<CommunicationHistoryPage> createState() =>
      _CommunicationHistoryPageState();
}

class _CommunicationHistoryPageState extends State<CommunicationHistoryPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  bool isLoading = true;
  List<Map<String, dynamic>> feedbacks = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    final fbSnap = await dbRef.child("CustomerRelationship/feedbacks").get();

    if (!fbSnap.exists) {
      setState(() => isLoading = false);
      return;
    }

    List<Map<String, dynamic>> temp = [];

    for (final child in fbSnap.children) {
      final fbData = Map<String, dynamic>.from(child.value as Map);

      if (fbData["status"] != "Closed") continue;

      final customerID = fbData["customerID"];
      final serviceID = (fbData["serviceID"] ?? "").trim();
      print("Looking for serviceID: '$serviceID'");

      final svcSnap = await dbRef.child("services/$serviceID").get();
      print("svcSnap.exists: ${svcSnap.exists}");
      print("svcSnap.value: ${svcSnap.value}");

      final serviceData = svcSnap.exists
          ? Map<String, dynamic>.from(svcSnap.value as Map)
          : {};



      // 🔹 Fetch customer record
      final custSnap = await dbRef.child("users/customers/$customerID").get();
      final customerData = custSnap.exists
          ? Map<String, dynamic>.from(custSnap.value as Map)
          : {};

      print("Fetching customer: users/customers/$customerID");
      print("custSnap.exists: ${custSnap.exists}");
      print("custSnap.value: ${custSnap.value}");

      temp.add({
        "feedbackID": child.key,
        "customerID": customerID,
        "customerName": customerData["custName"] ?? "Unknown",
        "carModel": serviceData["carModel"] ?? "-",
        "serviceType": serviceData["serviceType"] ?? "-",
        "serviceDate": serviceData["serviceDate"] ?? "-",
        "serviceFee": serviceData["serviceFee"] ?? 0,
        "serviceQuality": fbData["serviceQuality"] ?? 0,
        "completionEfficiency": fbData["completionEfficiency"] ?? 0,
        "engineeringAttitude": fbData["engineeringAttitude"] ?? 0,
        "comment": fbData["comment"] ?? "",
        "status": fbData["status"] ?? "Unknown",
      });
    }

    setState(() {
      feedbacks = temp;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixeroMainAppBar(
        title: "Communication History",
        searchHints: ["Customer Name", "Car Model", "Service Type"],
        searchTerms: const ["John Tan", "Toyota Vios", "Workshop Service"],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedbacks.isEmpty
          ? const Center(child: Text("No closed feedbacks found."))
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: feedbacks.length,
        itemBuilder: (context, index) {
          final fb = feedbacks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text("Customer: ${fb['customerName']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Service Car: ${fb['carModel']}"),
                  Text("Service Type: ${fb['serviceType']}"),
                  Text("Service Date: ${fb['serviceDate']}"),
                  Text("Feedback: ${fb['comment']}"),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ServiceFeedbackDetailPage(feedback: fb),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
