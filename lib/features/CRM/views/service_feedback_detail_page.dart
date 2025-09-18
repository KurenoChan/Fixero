import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ServiceFeedbackDetailPage extends StatefulWidget {
  final Map<String, dynamic> feedback;

  const ServiceFeedbackDetailPage({super.key, required this.feedback});

  @override
  State<ServiceFeedbackDetailPage> createState() =>
      _ServiceFeedbackDetailPageState();
}

class _ServiceFeedbackDetailPageState extends State<ServiceFeedbackDetailPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> replies = [];

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    final fbID = widget.feedback["feedbackID"];
    final replySnap =
    await dbRef.child("communications/replies/$fbID").get();

    if (!replySnap.exists) {
      setState(() => replies = []);
      return;
    }

    final replyData = Map<String, dynamic>.from(replySnap.value as Map);

    setState(() {
      replies = replyData.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value);
        return {
          "replyID": e.key,
          "from": data["from"] ?? "Unknown",
          "message": data["message"] ?? "",
          "date": data["date"] ?? "-",
        };
      }).toList();
    });
  }

  Future<void> _reopenFeedback() async {
    final fbID = widget.feedback["feedbackID"];

    await dbRef.child("communications/feedbacks/$fbID").update({
      "status": "Open",
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback has been reopened.")),
      );
      Navigator.pop(context, true); // ✅ return true to trigger refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final fb = widget.feedback;
    final isClosed =
        (fb["status"] ?? "").toString().trim().toLowerCase() == "closed";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback Detail"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔹 Customer & Service Info
            Text("Customer: ${fb['customerName']} (${fb['customerID']})",
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Car Model: ${fb['carModel']}"),
            Text("Service Type: ${fb['serviceType']}"),
            Text("Service Date: ${fb['serviceDate']}"),
            Text("Service Fee: RM ${fb['serviceFee']}"),
            const Divider(height: 30),

            // 🔹 Feedback details
            const Text("Feedback Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Service Quality: ${fb['serviceQuality']}"),
            Text("Completion Efficiency: ${fb['completionEfficiency']}"),
            Text("Engineering Attitude: ${fb['engineeringAttitude']}"),
            const SizedBox(height: 10),
            Text("Comment: ${fb['comment']}"),
            Text("Status: ${fb['status']}"),
            const Divider(height: 30),

            // 🔹 Replies
            const Text("Replies",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            replies.isEmpty
                ? const Text("No replies available.")
                : Column(
              children: replies.map((r) {
                return ListTile(
                  title: Text(r["from"]),
                  subtitle: Text(r["message"]),
                  trailing: Text(r["date"]),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 🔹 Reopen button if feedback is closed
            if (isClosed)
              ElevatedButton.icon(
                onPressed: _reopenFeedback,
                icon: const Icon(Icons.lock_open),
                label: const Text("Reopen Feedback"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
