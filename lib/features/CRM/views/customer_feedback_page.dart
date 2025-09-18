import 'package:flutter/material.dart';
import 'package:fixero/features/CRM/views/service_feedback_reply_page.dart';
import "../controllers/feedback_list_page.dart";

// Open feedback page (replyable)
class CustomerFeedbackPage extends StatelessWidget {
  const CustomerFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeedbackListPage(
      title: "Customer Feedback",
      statusFilter: "Open",
      detailPageBuilder: (fb) => ServiceFeedbackReplyPage(feedback: fb),
    );
  }
}
