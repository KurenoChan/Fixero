import 'package:fixero/common/widgets/bars/fixero_subappbar.dart';
import 'package:fixero/common/widgets/tools/fixero_searchbar.dart';
import 'package:flutter/material.dart';

class BrowseInventoryPage extends StatefulWidget {
  const BrowseInventoryPage({super.key});

  @override
  State<BrowseInventoryPage> createState() => _BrowseInventoryPageState();
}

class _BrowseInventoryPageState extends State<BrowseInventoryPage> {
  final List<Map<String, dynamic>> _itemCategories = [
    {"name": "Spare Parts", "icon": Icons.precision_manufacturing},
    {"name": "Tools & Equipments", "icon": Icons.build},
    {"name": "Fluids & Lubricants", "icon": Icons.water_drop},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixeroSubAppBar(title: "Browse Inventory"),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: CustomScrollView(
          slivers: <Widget>[
            // Search bar
            SliverToBoxAdapter(
              child: FixeroSearchBar(
                searchHints: ["Spare Parts", "Tools"],
                searchTerms: [],
                // onSearch: (text) {
                //   setState(() {
                //     _query = text;
                //   });
                // },
              ),
            ),

            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Category",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            _itemCategories.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "No categories available.",
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.fontSize,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final category = _itemCategories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _itemCategoryCard(
                          context,
                          category["name"]!,
                          category["icon"]!,
                        ),
                      );
                    }, childCount: _itemCategories.length),
                  ),
                  
          ],
        ),
      ),
    );
  }
}

Widget _itemCategoryCard(
  BuildContext context,
  String categoryName,
  IconData icon,
) {
  return GestureDetector(
    onTap: () => {
      // handle on tap
    },

    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          // Icon
          Icon(icon, size: 50, color: Theme.of(context).colorScheme.primary),
          // Category Name
          Text(
            categoryName,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
