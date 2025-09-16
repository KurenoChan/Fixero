import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../common/widgets/bars/fixero_mainappbar.dart';

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
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    final fbID = widget.feedback["feedbackID"];
    final replySnap =
    await dbRef.child("CustomerRelationship/replies/$fbID").get();

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

  Future<void> _addReply() async {
    final fbID = widget.feedback["feedbackID"];
    final newReplyKey =
        "RPL-${DateTime.now().toString().replaceAll(RegExp(r'[-: ]'), '').substring(0, 12)}";

    final replyData = {
      "from": "Manager",
      "message": _replyController.text,
      "date": DateTime.now().toString(),
    };

    await dbRef
        .child("CustomerRelationship/replies/$fbID/$newReplyKey")
        .set(replyData);

    _replyController.clear();
    _loadReplies(); // refresh replies
  }

  @override
  Widget build(BuildContext context) {
    final fb = widget.feedback;

    return Scaffold(
      appBar: FixeroMainAppBar(
        title: "Feedback Detail",
        searchHints: ["Customer Name", "Vehicle Plate", "Phone Number"],
        searchTerms: [
          "John Tan",
          "Toyota Vios",
          "0123456789",
          "Service Feedback",
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔹 Customer & Service Info
            Text("Customer: ${fb['customerName']} (${fb['customerID']})",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            const Divider(height: 30),

            // 🔹 Replies
            const Text("Replies",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            replies.isEmpty
                ? const Text("No replies yet.")
                : Column(
              children: replies
                  .map((r) => ListTile(
                title: Text(r["from"]),
                subtitle: Text(r["message"]),
                trailing: Text(r["date"]),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // 🔹 Add reply
            TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                labelText: "Your Reply",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addReply,
              icon: const Icon(Icons.send),
              label: const Text("Reply"),
            ),
          ],
        ),
      ),
    );
  }
}
