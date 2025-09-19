import 'package:flutter/material.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../../../common/widgets/bars/fixero_main_appbar.dart';
import 'package:fixero/features/CRM/views/customer_directory_page.dart';
import 'package:fixero/features/CRM/views/communication_history.dart';
import 'package:fixero/features/CRM/views/customer_feedback_page.dart';

// Import your feedback controller
import '../controllers/feedback_controller.dart';

class CrmHomePage extends StatefulWidget {
  static const routeName = '/crm';

  const CrmHomePage({super.key});

  @override
  State<CrmHomePage> createState() => _CrmHomePageState();
}

class _CrmHomePageState extends State<CrmHomePage> {
  final FeedbackController feedbackController = FeedbackController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: FixeroMainAppBar(
          title: "Customer Relationship",
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // 🔹 Row 1: Directory + Feedback
              Row(
                children: [
                  Expanded(
                    child: _buildCRMOptionCard(
                      theme: theme,
                      icon: Icons.people,
                      title: "Customer Directory",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerDirectoryPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: feedbackController,
                      builder: (context, unseenCount, _) {
                        return _buildCRMOptionCard(
                          theme: theme,
                          icon: Icons.feedback,
                          title: "Customer Feedback",
                          badgeCount: unseenCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerFeedbackPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 🔹 Row 2: Communication History (full width)
              _buildCRMOptionCard(
                theme: theme,
                icon: Icons.phone_in_talk,
                title: "Communication History",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunicationHistoryPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: FixeroBottomAppBar(),
      ),
    );
  }

  Widget _buildCRMOptionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: 4,
            shadowColor: Colors.black26,
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 50, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.pink, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
