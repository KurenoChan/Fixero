import 'package:flutter/material.dart';
import '../controllers/feedback_list_page.dart';
import '../models/feedback_model.dart';
import 'service_feedback_reply_page.dart';

class CustomerFeedbackPage extends StatelessWidget {
  const CustomerFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeedbackListPage(
      title: "Customer Feedback",
      statusFilter: "Open",
      detailPageBuilder: (FeedbackModel fb) => ServiceFeedbackReplyPage(feedback: fb),
    );
  }
}
