import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'package:fixero/features/inventory_management/controllers/item_controller.dart';
import 'package:fixero/features/inventory_management/models/item_usage.dart';
import 'package:fixero/features/inventory_management/views/item_details_page.dart';
import 'package:fixero/features/job_management/controllers/job_controller.dart';
import 'package:fixero/features/job_management/views/job_details_page.dart';
import 'package:fixero/utils/formatters/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsageDetailsPage extends StatefulWidget {
  final ItemUsage usage;

  const UsageDetailsPage({super.key, required this.usage});

  @override
  State<UsageDetailsPage> createState() => _UsageDetailsPageState();
}

class _UsageDetailsPageState extends State<UsageDetailsPage> {
  @override
  void initState() {
    super.initState();

    final jobController = context.read<JobController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (jobController.jobs.isEmpty) {
        await jobController.loadJobs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemController = context.watch<ItemController>();
    final item = itemController.getItemByID(widget.usage.itemID);
    final itemUsage = widget.usage;

    final jobController = context.read<JobController>();
    final job = jobController.getJobByJobID(widget.usage.jobID);

    return SafeArea(
      child: Scaffold(
        appBar: const FixeroSubAppBar(
          title: "Usage Details",
          showBackButton: true,
        ),
        body: Column(
          children: [
            // 🔹 Only show image if item is found
            if (item != null && item.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    item.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withAlpha(50),
                      blurRadius: 15,
                      offset: const Offset(0, -15),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    // 🔹 Item Name + Usage No
                    Column(
                      spacing: 10.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            item?.itemName ?? "Unknown Item",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.inverseSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            itemUsage.itemUsageNo,
                            style: TextStyle(
                              fontSize: Theme.of(
                                context,
                              ).textTheme.bodySmall?.fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Usage Date & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              itemUsage.usageDate.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              Formatter.formatTime12Hour(
                                itemUsage.usageTime.toString(),
                                showSeconds: true,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Quantity Used and In Stock
                    Row(
                      spacing: 10.0,
                      children: [
                        if (itemUsage.quantityUsed != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface, // <-- add background
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary
                                      .withValues(alpha: 0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.shadow.withAlpha(50),
                                    blurRadius: 4, // slightly stronger shadow
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text("Quantity Used"),
                                  Text(
                                    itemUsage.quantityUsed.toString(),
                                    style: TextStyle(
                                      fontSize: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface, // <-- add background
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary
                                    .withValues(alpha: 0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.shadow.withAlpha(50),
                                  blurRadius: 4, // slightly stronger shadow
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text("In Stock"),
                                Text(
                                  item!.stockQuantity.toString(),
                                  style: TextStyle(
                                    fontSize: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Remark",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    (itemUsage.remark != null &&
                            itemUsage.remark!.trim().isNotEmpty)
                        ? Text(
                            itemUsage.remark!.trim(),
                            textAlign: TextAlign.justify,
                          )
                        : const Text(
                            "No remark available",
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                  ],
                ),
              ),
            ),

            Container(
              height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.inverseSurface.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 10.0,
                children: [
                  // 🔹 Job Details Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (job != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailsPage(job: job),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 15.0,
                        ),
                        backgroundColor: Theme.of(context).primaryColorDark,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 5.0,
                        children: [
                          const Icon(Icons.work, size: 25),
                          Text(
                            'Job Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(
                                context,
                              ).textTheme.titleMedium?.fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailsPage(itemID: item.itemID),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 15.0,
                        ),
                        backgroundColor: const Color.fromRGBO(16, 185, 129, 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 5.0,
                        children: [
                          const Icon(Icons.inventory_2, size: 25),
                          Text(
                            'Item Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(
                                context,
                              ).textTheme.titleMedium?.fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
