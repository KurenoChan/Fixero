import 'package:flutter/material.dart';
import 'package:fixero/features/CRM/views/service_feedback_detail_page.dart';
import "../controllers/feedback_list_page.dart";


class CommunicationHistoryPage extends StatelessWidget {
  const CommunicationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeedbackListPage(
      title: "Communication History",
      statusFilter: "Closed",
      detailPageBuilder: (fb) => ServiceFeedbackDetailPage(feedback: fb),
    );
  }
}