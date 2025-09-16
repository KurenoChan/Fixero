import 'package:flutter/material.dart';
import '../../../common/widgets/bars/fixero_bottomappbar.dart';
import '../../../common/widgets/bars/fixero_mainappbar.dart';
import 'package:fixero/features/CRM/views/CusDirectory.dart';
import 'package:fixero/features/CRM/views/communicationHistoy.dart';
class CrmHomePage extends StatefulWidget {
  static const routeName = '/crm';

  const CrmHomePage({super.key});

  @override
  State<CrmHomePage> createState() => _CrmHomePageState();
}

class _CrmHomePageState extends State<CrmHomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: FixeroMainAppBar(
          title: "Customer Relationship",
          searchHints: ["Customer Name", "Vehicle Plate", "Phone Number"],
          searchTerms: [
            "John Tan",
            "Toyota Vios",
            "0123456789",
            "Service Feedback",
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: <Widget>[
            // Customer Directory
            _buildCRMOptionCard(
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

            const SizedBox(height: 10),

            Row(
              children: [
                // Communication History
                Expanded(
                  child: _buildCRMOptionCard(
                    theme: theme,
                    icon: Icons.phone_in_talk,
                    title: "Communication History",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CommunicationHistoryPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Customer Feedback
                Expanded(
                  child: _buildCRMOptionCard(
                    theme: theme,
                    icon: Icons.feedback,
                    title: "Customer Feedback",
                    onTap: () {
                      // TODO: Navigate to Customer Feedback page
                    },
                  ),
                ),
              ],
            ),
          ],
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
        fit: StackFit.passthrough,
        children: [
          Card(
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(icon, size: 50, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (badgeCount > 0)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.pink, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}