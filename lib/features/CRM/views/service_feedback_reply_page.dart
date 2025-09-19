import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/feedback_model.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../../../common/widgets/bars/fixero_sub_appbar.dart';
import '../widgets/feedback_layout_widget.dart';
import 'package:intl/intl.dart';
import '../../authentication/controllers/manager_controller.dart';
class ServiceFeedbackReplyPage extends StatefulWidget {
  final FeedbackModel feedback;
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
    final fbID = widget.feedback.feedbackID; // ✅ use model property
    final replySnap = await dbRef.child("communications/replies/$fbID").get();

    if (!replySnap.exists) {
      setState(() => replies = []);
      return;
    }

    List<Map<String, dynamic>> temp = [];

    for (final child in replySnap.children) {
      final data = Map<String, dynamic>.from(child.value as Map);
      temp.add({
        "replyID": child.key,
        "from": data["from"] ?? "Unknown",
        "message": data["message"] ?? "",
        "date": data["date"] ?? "-",
      });
    }

    setState(() => replies = temp);
  }

  Future<void> _addReply() async {
    if (_replyController.text.trim().isEmpty) return;

    final fbID = widget.feedback.feedbackID;
    final newReplyKey =
        "RPL-${DateTime.now().toString().replaceAll(RegExp(r'[-: ]'), '').substring(0, 12)}";

    // 🔹 Get logged in manager profile
    final currentManager = await ManagerController.getCurrentManager();

    final formattedDate = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());

    final replyData = {
      "from": currentManager != null
          ? "${currentManager.role} - ${currentManager.name}"
          : "Unknown",
      "message": _replyController.text.trim(),
      "date": formattedDate,
    };

    await dbRef.child("communications/replies/$fbID/$newReplyKey").set(replyData);

    _replyController.clear();
    _loadReplies();
  }


  Future<void> _closeFeedback() async {
    final fbID = widget.feedback.feedbackID; // ✅ use model property

    await dbRef.child("communications/feedbacks/$fbID").update({
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const FixeroSubAppBar(title: "Feedback Detail", showBackButton: true),
      bottomNavigationBar: const FixeroBottomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: buildFeedbackLayout(
          fb: fb,
          replies: replies,
          context: context,
          actions: [
            // reply input
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _replyController,
                      decoration: const InputDecoration(
                        labelText: "Your Reply",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
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
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _closeFeedback,
              icon: const Icon(Icons.lock),
              label: const Text("Close Feedback"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
