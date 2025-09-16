import 'package:fixero/data/dao/inventory/requested_item_dao.dart';
import 'package:fixero/data/repositories/users/manager_repository.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/controllers/restock_request_controller.dart';
import 'package:fixero/features/inventory_management/models/requested_item.dart';
import 'package:fixero/features/inventory_management/views/request_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/bars/fixero_sub_appbar.dart';

class RequestsOrdersPage extends StatefulWidget {
  const RequestsOrdersPage({super.key});

  @override
  State<RequestsOrdersPage> createState() => _RequestsOrdersPageState();
}

class _RequestsOrdersPageState extends State<RequestsOrdersPage>
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

    // Ensure ItemController loads first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemController = context.read<ItemController>();
      final restockController = context.read<RestockRequestController>();

      // Load all items first
      if (itemController.items.isEmpty) {
        await itemController.loadItems();
      }

      // Then load pending requests
      await restockController.loadRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Placeholder list widgets for now
  Widget _buildPendingRequests() {
    final restockController = context.watch<RestockRequestController>();
    final itemController = context.read<ItemController>();

    if (restockController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendingRequests = restockController.pendingRequests;

    if (pendingRequests.isEmpty) {
      return const Center(child: Text("No pending requests"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];

        return FutureBuilder(
          future: Future.wait([
            RequestedItemDAO().getItemsByRequestId(request.requestId),
            ManagerRepository().getManager(request.requestBy),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text("Error loading request: ${snapshot.error}"),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(title: Text("Loading...")),
              );
            }

            final requestedItems = snapshot.data![0] as List<RequestedItem>;
            final manager = snapshot.data![1];

            // Map requested items to actual items, filtering invalid images
            final itemsForGrid = requestedItems
                .map((ri) => itemController.getItemById(ri.itemId))
                .where((item) => item != null)
                .take(4) // max 4 items
                .toList();

            return GestureDetector(
              onTap: () {
                // show bottom sheet of the request details with all the requested items for that request
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // allows full screen
                  backgroundColor: Colors.transparent,
                  builder: (context) => RequestDetailsSheet(request: request),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(5),
                  leading: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    width: 80,
                    height: 80,
                    child: itemsForGrid.isEmpty
                        ? const Center(child: Text("No image"))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final count = itemsForGrid.length;
                              if (count == 1) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    itemsForGrid[0]!.imageUrl,
                                    fit: BoxFit.cover,
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Text('No image'),
                                            ),
                                  ),
                                );
                              } else if (count == 2) {
                                return Row(
                                  spacing: 2.0,
                                  children: itemsForGrid
                                      .map(
                                        (item) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(1),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: Image.network(
                                                width: double.infinity,
                                                height: double.infinity,
                                                item!.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Center(
                                                      child: Text('No image'),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              } else if (count == 3) {
                                return Column(
                                  spacing: 2.0,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        spacing: 2.0,
                                        children: itemsForGrid
                                            .take(2)
                                            .map(
                                              (item) => Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    1,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2.0,
                                                        ),
                                                    child: Image.network(
                                                      item!.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Center(
                                                            child: Text(
                                                              'No image',
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          3.0,
                                        ),
                                        child: SizedBox(
                                          width: constraints.maxWidth,
                                          child: Image.network(
                                            itemsForGrid[2]!.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: Text('No image'),
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // 4 images
                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 2,
                                        crossAxisSpacing: 2,
                                      ),
                                  itemCount: 4,
                                  itemBuilder: (context, i) {
                                    final item = itemsForGrid[i]!;
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(2.0),
                                      child: Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Text('No image'),
                                                ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                  ),
                  title: Text(
                    request.requestId,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Theme.of(
                        context,
                      ).textTheme.titleMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    spacing: 5.0,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.3),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              request.requestDate,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              request.requestTime,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'By: ${manager?.name ?? "Unknown"}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.close,
                          color: const Color.fromARGB(255, 184, 13, 1),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          // await _approveRequest(context, request);
                        },
                        icon: Icon(
                          Icons.check,
                          color: const Color.fromARGB(255, 0, 145, 5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
