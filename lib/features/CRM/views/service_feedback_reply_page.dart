import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ServiceFeedbackReplyPage extends StatefulWidget {
  final Map<String, dynamic> feedback;

  const ServiceFeedbackReplyPage({super.key, required this.feedback});

  @override
  State<ServiceFeedbackReplyPage> createState() =>
      _ServiceFeedbackReplyPageState();
}

class _ServiceFeedbackReplyPageState extends State<ServiceFeedbackReplyPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _replyController = TextEditingController();
  List<Map<String, dynamic>> replies = [];

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    final fbID = widget.feedback["feedbackID"];
    final replySnap =
    await dbRef.child("customerRelationship/replies/$fbID").get();

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
    if (_replyController.text.trim().isEmpty) return;

    final fbID = widget.feedback["feedbackID"];
    final newReplyKey =
        "RPL-${DateTime.now().toString().replaceAll(RegExp(r'[-: ]'), '').substring(0, 12)}";

    final replyData = {
      "from": "Manager",
      "message": _replyController.text.trim(),
      "date": DateTime.now().toString(),
    };

    await dbRef
        .child("customerRelationship/replies/$fbID/$newReplyKey")
        .set(replyData);

    _replyController.clear();
    _loadReplies();
  }

  Future<void> _closeFeedback() async {
    final fbID = widget.feedback["feedbackID"];

    await dbRef.child("customerRelationship/feedbacks/$fbID").update({
      "status": "Closed",
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback has been closed.")),
      );
      Navigator.pop(context, true); // go back & refresh previous list
    }
  }

  @override
  Widget build(BuildContext context) {
    final fb = widget.feedback;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reply to Feedback"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Feedback Info
            Text("Customer: ${fb['customerName']}"),
            Text("Car Model: ${fb['carModel']}"),
            Text("Service Type: ${fb['serviceType']}"),
            Text("Comment: ${fb['comment']}"),
            const Divider(height: 30),

            // Replies
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

            // Add Reply
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
            const SizedBox(height: 20),

            // Close Feedback Button
            ElevatedButton.icon(
              onPressed: _closeFeedback,
              icon: const Icon(Icons.lock),
              label: const Text("Close Feedback"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
