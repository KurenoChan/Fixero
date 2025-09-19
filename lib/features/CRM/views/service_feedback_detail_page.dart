import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/feedback_model.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../../../common/widgets/bars/fixero_sub_appbar.dart';
import 'customer_profile_page.dart'; // make sure path correct

class ServiceFeedbackDetailPage extends StatefulWidget {
  final FeedbackModel feedback;

  const ServiceFeedbackDetailPage({super.key, required this.feedback});

  @override
  State<ServiceFeedbackDetailPage> createState() =>
      _ServiceFeedbackDetailPageState();
}

// 🔹 Feedback ratings section
Widget _buildRatingRow(String label, int value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "$label:",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: List.generate(5, (index) {
              return Icon(
                index < value ? Icons.star : Icons.star_border,
                color: Colors.amber.shade700,
                size: 22,
              );
            }),
          ),
        ),
      ],
    ),
  );
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
    final fbID = widget.feedback.feedbackID;
    final replySnap = await dbRef.child("communications/replies/$fbID").get();

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
    final fbID = widget.feedback.feedbackID;

    await dbRef.child("communications/feedbacks/$fbID").update({
      "status": "Open",
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback has been reopened.")),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fb = widget.feedback;
    final isClosed = fb.status.toLowerCase() == "closed";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const FixeroSubAppBar(title: "Feedback Detail", showBackButton: true),
      bottomNavigationBar: const FixeroBottomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔹 Customer & Job Info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer: ${fb.customerName}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text("Car Model: ${fb.carModel}",
                        style: const TextStyle(color: Colors.black87)),
                    Text("Service Type: ${fb.serviceType}",
                        style: const TextStyle(color: Colors.black87)),
                    Text("Service Date: ${fb.date}",
                        style: const TextStyle(color: Colors.black87)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (fb.customerId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerProfilePage(
                                customerId: fb.customerId!,   // now filled
                                customerData: {},             // can let profile fetch its own
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No customer linked to this feedback")),
                          );
                        }
                      },
                      icon: const Icon(Icons.person),
                      label: const Text("View Customer Profile"),
                    )

                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Feedback ratings
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Feedback Ratings",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildRatingRow("Service Quality", fb.serviceQuality),
                    _buildRatingRow("Completion Time", fb.completionEfficiency),
                    _buildRatingRow("Engineering Attitude", fb.engineeringAttitude),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Feedback details (comment)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Comment",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(fb.comment,
                        style: const TextStyle(fontSize: 15, color: Colors.black87)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Replies
            const Text("Replies",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            replies.isEmpty
                ? const Text("No replies available.")
                : Column(
              children: replies.map((r) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      r["from"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(r["message"],
                          style: const TextStyle(color: Colors.black87)),
                    ),
                    trailing: Text(
                      r["date"],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
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
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
