import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../views/customer_profile_page.dart'; // ✅ adjust path if needed

/// 🔹 Reusable feedback layout for both Detail & Reply pages
Widget buildFeedbackLayout({
  required FeedbackModel fb,
  required List<Map<String, dynamic>> replies,
  required List<Widget> actions, // buttons / reply input section
  required BuildContext context,
  Function(String replyID)? onDeleteReply,
}) {
  return ListView(
    children: [
      // 🔹 Customer & Job Info
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
              Row(
                children: const [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Customer & Job Info",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              // 🔹 Info rows
              _buildInfoRow("Customer", fb.customerName ?? "-"),
              _buildInfoRow("Car Model", fb.carModel ?? "-"),
              _buildInfoRow("Service Type", fb.serviceType ?? "-"),
              _buildInfoRow("Service Date", fb.date),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (fb.customerId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerProfilePage(
                            customerId: fb.customerId!,
                            customerData: {},
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No customer linked")),
                      );
                    }
                  },
                  icon: const Icon(Icons.person),
                  label: const Text("View Profile"),
                ),
              )
            ],
          ),
        ),
      ),

      const SizedBox(height: 20),

      // 🔹 Ratings
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

      // 🔹 Comment
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
              Row(
                children: const [
                  Icon(Icons.comment, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Customer Comment",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fb.comment,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
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
              title: Text(r["from"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(r["message"],
                    style: const TextStyle(color: Colors.black87)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(r["date"],
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  if (onDeleteReply != null) // ✅ only show delete in ReplyPage
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red, size: 20),
                      onPressed: () => onDeleteReply(r["replyID"]),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),

      // 🔹 Actions (reopen OR reply + close)
      ...actions,
    ],
  );
}
Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text("$label:",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
        ),
        Expanded(
          flex: 3,
          child: Text(value,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ),
      ],
    ),
  );
}

/// 🔹 Helper for displaying rating stars
Widget _buildRatingRow(String label, int value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < value ? Icons.star : Icons.star_border,
              color: Colors.amber.shade700,
              size: 22,
            );
          }),
        ),
      ],
    ),
  );
}

