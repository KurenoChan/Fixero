import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/feedback_model.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../../../common/widgets/bars/fixero_sub_appbar.dart';
import 'customer_profile_page.dart'; // make sure path correct
import '../widgets/feedback_layout_widget.dart';

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

    List<Map<String, dynamic>> temp = replyData.entries.map((e) {
      final data = Map<String, dynamic>.from(e.value);
      return {
        "replyID": e.key,
        "from": data["from"] ?? "Unknown",
        "message": data["message"] ?? "",
        "date": data["date"] ?? "-",
      };
    }).toList();

    // 🔹 sort replies by date ascending (latest at bottom)
    temp.sort((a, b) {
      final dateA = DateTime.tryParse(a["date"]) ?? DateTime(1970);
      final dateB = DateTime.tryParse(b["date"]) ?? DateTime(1970);
      return dateA.compareTo(dateB);
    });

    setState(() => replies = temp);
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
        child: buildFeedbackLayout(
          fb: fb,
          replies: replies,
          context: context,
          actions: isClosed
              ? [
            ElevatedButton.icon(
              onPressed: _reopenFeedback,
              icon: const Icon(Icons.lock_open),
              label: const Text("Reopen Feedback"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            )
          ]
              : [],
        ),
      ),

    );
  }
}
