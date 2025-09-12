import 'package:flutter/material.dart';

class FixeroSearchBar extends StatefulWidget {
  final List<String> searchHints;
  final List<String> searchTerms;

  const FixeroSearchBar({
    super.key,
    required this.searchHints,
    required this.searchTerms,
  });

  @override
  State<FixeroSearchBar> createState() => _FixeroSearchBarState();
}

class _FixeroSearchBarState extends State<FixeroSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search ${widget.searchHints.map((e) => e.toLowerCase()).join(", ")}, etc.',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {

        },
      ),
    );
  }
}
