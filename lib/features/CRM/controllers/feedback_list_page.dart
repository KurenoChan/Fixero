import 'package:flutter/material.dart';

import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
// adjust these two imports if your file is in a different folder
import '../../../common/widgets/bars/fixero_sub_appbar.dart';
import '../controllers/customer_controller.dart';
import '../controllers/feedback_controller.dart';
import '../models/customer_model.dart'; // ✅ add this line
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
  final CustomerController customerController = CustomerController();
  final FeedbackController feedbackController = FeedbackController();

  Color _getCardColor(String feedbackType) {
    switch (feedbackType) {
      case "Positive":
        return Colors.green.shade100; // light pastel green
      case "Complaint":
        return Colors.red.shade100; // light pastel red
      case "Suggestion":
        return Colors.blue.shade100; // light pastel blue
      default:
        return Colors.grey.shade200; // neutral light grey
    }
  }

  // Filters
  String searchQuery = "";
  String selectedFeedbackType = "All";
  String selectedServiceType = "All";
  String sortOrder = "Latest";

  final TextEditingController _searchController = TextEditingController();

  final List<String> feedbackTypes = [
    "All",
    "Positive",
    "Complaint",
    "Suggestion",
  ];
  final List<String> serviceTypes = [
    "All",
    "Vehicle Safety Check",
    "Car Repair",
    "Battery Repair",
    "Fuel Tank Maintenance",
    "Tire Repair",
  ];

  String _getServiceIcon(String serviceType) {
    if (serviceType.isEmpty) return "assets/icons/services_Icon/default.png";
    final fileName = serviceType
        .toLowerCase()
        .replaceAll(" ", "_")
        .replaceAll("-", "_")
        .replaceAll("/", "_");
    return "assets/icons/services_Icon/$fileName.png";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixeroSubAppBar(title: widget.title, showBackButton: true),
      body: ValueListenableBuilder<bool>(
        valueListenable: feedbackController.ready,
        builder: (context, ready, _) {
          if (!ready) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<int>(
            valueListenable: feedbackController,
            builder: (context, _, __) {
              // get feedbacks with correct status
              var feedbacks = feedbackController.allFeedbacks
                  .where(
                    (f) =>
                        f.status.toLowerCase() ==
                        widget.statusFilter.toLowerCase(),
                  )
                  .toList();

              // apply search filter
              if (_searchController.text.trim().isNotEmpty) {
                final q = _searchController.text.toLowerCase().trim();
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
                feedbacks = feedbacks
                    .where((f) => f.feedbackType == selectedFeedbackType)
                    .toList();
              }
              if (selectedServiceType != "All") {
                feedbacks = feedbacks
                    .where((f) => f.serviceType == selectedServiceType)
                    .toList();
              }

              // sort unseen first, then by date according to sortOrder
              feedbacks.sort((a, b) {
                // 1. Unseen first
                final unseenA = (a.seenStatus).toLowerCase() == "unseen";
                final unseenB = (b.seenStatus).toLowerCase() == "unseen";
                if (unseenA != unseenB) return unseenA ? -1 : 1;

                // 2. Sort by date
                DateTime? dateA;
                DateTime? dateB;
                try {
                  dateA = DateTime.parse(a.date);
                  dateB = DateTime.parse(b.date);
                } catch (_) {}

                if (dateA == null && dateB == null) return 0;
                if (dateA == null) return sortOrder == "Latest" ? 1 : -1;
                if (dateB == null) return sortOrder == "Latest" ? -1 : 1;

                return sortOrder == "Latest"
                    ? dateB.compareTo(dateA)
                    : dateA.compareTo(dateB);
              });

              return Column(
                children: [
                  // 🔹 Search + Sort Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 🔎 Search input
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {}); // trigger filtering
                              },
                              textAlignVertical: TextAlignVertical.center,
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                icon: Icon(Icons.search, color: Colors.blue),
                                hintText: "Search feedback...",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                // ✅ remove underline when not focused
                                focusedBorder: InputBorder.none,
                                // ✅ remove underline when focused
                                errorBorder: InputBorder.none,
                                // ✅ safety (in case of error state)
                                disabledBorder: InputBorder.none,
                                // ✅ safety
                                filled: false,
                              ),
                            ),
                          ),

                          // ↕ Sort menu inside the search bar
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.sort, color: Colors.blue),
                            onSelected: (value) {
                              setState(() {
                                sortOrder = value;
                              });
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "Latest",
                                child: Text("Latest"),
                              ),
                              const PopupMenuItem(
                                value: "Oldest",
                                child: Text("Oldest"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // filters row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Feedback Type Filter
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedFeedbackType,
                                hint: const Text("Feedback Type"),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.blue,
                                ),
                                items: feedbackTypes
                                    .map(
                                      (ft) => DropdownMenuItem(
                                        value: ft,
                                        child: Text(ft),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                      () => selectedFeedbackType = value,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Service Type Filter
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedServiceType,
                                hint: const Text("Service Type"),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.blue,
                                ),
                                items: serviceTypes
                                    .map(
                                      (st) => DropdownMenuItem(
                                        value: st,
                                        child: Text(st),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => selectedServiceType = value);
                                  }
                                },
                              ),
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
                              final iconPath = _getServiceIcon(
                                fb.serviceType ?? "",
                              );
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: _getCardColor(fb.feedbackType),
                                // ✅ custom background color
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.white, // keep contrast
                                    child: Image.asset(
                                      iconPath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  title: ValueListenableBuilder<int>(
                                    valueListenable: customerController,
                                    builder: (context, _, __) {
                                      Customer? cust;
                                      try {
                                        cust = customerController.allCustomers
                                            .firstWhere(
                                              (c) => c.custID == fb.customerId,
                                            );
                                      } catch (_) {
                                        cust = null;
                                      }

                                      return Text(
                                        cust?.custName ??
                                            fb.customerName ??
                                            "Unknown",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),

                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Service: ${fb.serviceType ?? '-'}",
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        "Feedback: ${fb.feedbackType}",
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        "Car: ${fb.carModel ?? '-'}",
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        "Date: ${fb.date}",
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: fb.seenStatus == "Unseen"
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .red, // ✅ solid red background
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            "Unseen",
                                            style: TextStyle(
                                              color: Colors
                                                  .white, // ✅ white text on red
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,

                                  onTap: () async {
                                    if (fb.seenStatus == "Unseen") {
                                      await feedbackController.markSeen(
                                        fb.feedbackID,
                                      );
                                    }
                                    if (!context.mounted) return;
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            widget.detailPageBuilder(fb),
                                      ),
                                    );
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
      bottomNavigationBar: const FixeroBottomAppBar(),
    );
  }
}
