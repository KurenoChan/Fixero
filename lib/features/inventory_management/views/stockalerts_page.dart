import 'package:flutter/material.dart';

import '../../../common/widgets/bars/fixero_subappbar.dart';
import '../../../common/widgets/tools/fixero_searchbar.dart';

class StockAlertsPage extends StatefulWidget {
  const StockAlertsPage({super.key});

  @override
  State<StockAlertsPage> createState() => _StockAlertsPageState();
}

class _StockAlertsPageState extends State<StockAlertsPage> {
  final List<Map<String, String>> _items = [
    {"name": "Oil Change", "status": "All"},
    {"name": "Tire Rotation", "status": "Running Low"},
    {"name": "Battery Check", "status": "Out of Stock"},
    {"name": "Brake Inspection", "status": "All"},
    {"name": "Engine Tune-up", "status": "Running Low"},
    {"name": "Air Filter Replacement", "status": "Out of Stock"},
  ];

  String _filter = "All";
  final String _query = "";

  @override
  Widget build(BuildContext context) {
    final filteredItems = _items.where((item) {
      final matchesFilter = _filter == "All" || item["status"] == _filter;
      final matchesSearch =
      item["name"]!.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return SafeArea(
      child: Scaffold(
        appBar: FixeroSubAppBar(title: "Stock Alerts"),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: CustomScrollView(
            slivers: <Widget>[
              // Search bar
              SliverToBoxAdapter(
                child: FixeroSearchBar(
                  searchHints: ["Spare Parts", "Tools"],
                  searchTerms: _items.map((e) => e["name"]!).toList(),
                  // onSearch: (text) {
                  //   setState(() {
                  //     _query = text;
                  //   });
                  // },
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text("All"),
                        selected: _filter == "All",
                        onSelected: (_) => setState(() => _filter = "All"),
                      ),
                      ChoiceChip(
                        label: const Text("Running Low"),
                        selected: _filter == "Running Low",
                        onSelected: (_) =>
                            setState(() => _filter = "Running Low"),
                      ),
                      ChoiceChip(
                        label: const Text("Out of Stock"),
                        selected: _filter == "Out of Stock",
                        onSelected: (_) =>
                            setState(() => _filter = "Out of Stock"),
                      ),
                    ],
                  ),
                ),
              ),

              // Stock list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    final item = filteredItems[index];
                    return ListTile(
                      title: Text(item["name"]!),
                      subtitle: Text(item["status"]!),
                      leading: const Icon(Icons.inventory_2_rounded),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle item tap
                      },
                    );
                  },
                  childCount: filteredItems.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
