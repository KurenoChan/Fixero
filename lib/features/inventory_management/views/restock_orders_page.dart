import 'package:flutter/material.dart';
import '../../../common/widgets/bars/fixero_sub_appbar.dart';

class RestockOrdersPage extends StatefulWidget {
  const RestockOrdersPage({super.key});

  @override
  State<RestockOrdersPage> createState() => _RestockOrdersPageState();
}

class _RestockOrdersPageState extends State<RestockOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: 'Pending Requests'),
    Tab(text: 'Pending Orders'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Placeholder list widgets for now
  Widget _buildPendingRequests() {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 5, // Replace with your dynamic data
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('Request #${index + 1}'),
            subtitle: const Text('Waiting for approval'),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                // Navigate to request details page
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingOrders() {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 3, // Replace with your dynamic data
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('Order #${index + 1}'),
            subtitle: const Text('Waiting to be marked as received'),
            trailing: IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // Mark order as received
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FixeroSubAppBar(
        title: 'Restock & Orders',
        showBackButton: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: _tabs,
            labelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildPendingRequests(), _buildPendingOrders()],
            ),
          ),
        ],
      ),
    );
  }
}
