import 'package:flutter/material.dart';
import '../controllers/feedback_list_page.dart';
import '../models/feedback_model.dart';
import 'service_feedback_detail_page.dart';

class CommunicationHistoryPage extends StatelessWidget {
  const CommunicationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeedbackListPage(
      title: "Communication History",
      statusFilter: "Closed",
      detailPageBuilder: (FeedbackModel fb) => ServiceFeedbackDetailPage(feedback: fb),
    );
  }
}
