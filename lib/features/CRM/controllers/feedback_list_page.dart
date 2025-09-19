import 'package:flutter/material.dart';

// adjust these two imports if your file is in a different folder
import '../../../common/widgets/bars/fixero_sub_appbar.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';

import '../controllers/feedback_controller.dart';
import '../models/feedback_model.dart';

typedef FeedbackDetailBuilder = Widget Function(FeedbackModel feedback);

class FeedbackListPage extends StatefulWidget {
  final String title;
  final String statusFilter; // "Open" or "Closed"
  final FeedbackDetailBuilder detailPageBuilder;

  const FeedbackListPage({
    super.key,
    required this.title,
    required this.statusFilter,
    required this.detailPageBuilder,
  });

  @override
  State<FeedbackListPage> createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  final FeedbackController feedbackController = FeedbackController();

  // Filters
  String searchQuery = "";
  String selectedFeedbackType = "All";
  String selectedServiceType = "All";

  final List<String> feedbackTypes = ["All", "Positive", "Complaint", "Suggestion"];
  final List<String> serviceTypes = [
    "All",
    "Vehicle Safety Check",
    "Car Repair",
    "Battery Repair",
    "Fuel Tank Maintenance",
    "Tire Repair"
  ];

  String _getServiceIcon(String serviceType) {
    if (serviceType.isEmpty) {
      return "assets/icons/services_Icon/default.png";
    }
    final fileName = serviceType
        .toLowerCase()
        .replaceAll(" ", "_")
        .replaceAll("-", "_")
        .replaceAll("/", "_");
    return "assets/icons/services_Icon/$fileName.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // use your custom sub app bar (keeps your app's visual language)
      appBar: FixeroSubAppBar(
        title: widget.title,
        showBackButton: true,
      ),

      // Outer: wait until controller.ready == true
      body: ValueListenableBuilder<bool>(
        valueListenable: feedbackController.ready,
        builder: (context, ready, _) {
          if (!ready) {
            return const Center(child: CircularProgressIndicator());
          }

          // once ready, rebuild based on controller.value (unseen count) so list updates
          return ValueListenableBuilder<int>(
            valueListenable: feedbackController,
            builder: (context, _, __) {
              // get feedbacks with correct status
              var feedbacks = feedbackController.allFeedbacks
                  .where((f) => f.status.toLowerCase() == widget.statusFilter.toLowerCase())
                  .toList();

              // apply search filter
              if (searchQuery.isNotEmpty) {
                final q = searchQuery.toLowerCase();
                feedbacks = feedbacks.where((f) {
                  final cust = (f.customerName ?? '').toLowerCase();
                  final car = (f.carModel ?? '').toLowerCase();
                  final svc = (f.serviceType ?? '').toLowerCase();
                  return cust.contains(q) ||
                      car.contains(q) ||
                      f.comment.toLowerCase().contains(q) ||
                      svc.contains(q);
                }).toList();
              }

              // apply dropdown filters
              if (selectedFeedbackType != "All") {
                feedbacks = feedbacks.where((f) => f.feedbackType == selectedFeedbackType).toList();
              }
              if (selectedServiceType != "All") {
                feedbacks = feedbacks.where((f) => f.serviceType == selectedServiceType).toList();
              }

              // sort unseen first
              feedbacks.sort((a, b) {
                if (a.seenStatus == "Unseen" && b.seenStatus != "Unseen") return -1;
                if (a.seenStatus != "Unseen" && b.seenStatus == "Unseen") return 1;
                return 0;
              });

              return Column(
                children: [
                  // search input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search feedbacks...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value.trim());
                      },
                    ),
                  ),

                  // filters row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedFeedbackType,
                            items: feedbackTypes
                                .map((ft) => DropdownMenuItem(value: ft, child: Text(ft)))
                                .toList(),
                            onChanged: (value) {
                              setState(() => selectedFeedbackType = value ?? "All");
                            },
                            decoration: const InputDecoration(
                              labelText: "Feedback Type",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedServiceType,
                            items: serviceTypes
                                .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                                .toList(),
                            onChanged: (value) {
                              setState(() => selectedServiceType = value ?? "All");
                            },
                            decoration: const InputDecoration(
                              labelText: "Service Type",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // list
                  Expanded(
                    child: feedbacks.isEmpty
                        ? const Center(child: Text("No feedbacks found."))
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
                        final fb = feedbacks[index];
                        final iconPath = _getServiceIcon(fb.serviceType ?? "");

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              child: Image.asset(iconPath, fit: BoxFit.contain),
                            ),
                            title: Text(
                              fb.customerName ?? "Unknown",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Service: ${fb.serviceType ?? '-'}"),
                                Text("Feedback: ${fb.feedbackType}"),
                                Text("Car: ${fb.carModel ?? '-'}"),
                                Text("Date: ${fb.date}"),
                              ],
                            ),
                            trailing: fb.seenStatus == "Unseen"
                                ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Unseen",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                                : null,
                            onTap: () async {
                              // Mark seen locally + DB (optimistic)
                              if (fb.seenStatus == "Unseen") {
                                await feedbackController.markSeen(fb.feedbackID);
                              }

                              // Navigate; pass the model to the detail builder
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => widget.detailPageBuilder(fb),
                                ),
                              );

                              // controller is already synced, so no extra reload needed
                              if (result == true) {
                                // no-op
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),

      // bottom bar (your custom app bottom bar)
      bottomNavigationBar: const FixeroBottomAppBar(),
    );
  }
}
