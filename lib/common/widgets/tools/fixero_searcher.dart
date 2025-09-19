import 'package:flutter/material.dart';

typedef SearchResultCallback = void Function(String selected);

class FixeroSearcher extends StatelessWidget {
  final List<String> searchHints;
  final List<String> searchTerms;
  final SearchResultCallback onItemSelected;

  const FixeroSearcher({
    super.key,
    required this.searchHints,
    required this.searchTerms,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.search,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 30,
      ),
      onPressed: () async {
        final result = await showSearch<String?>(
          context: context,
          delegate: _CustomSearchDelegate(searchHints, searchTerms),
        );

        if (!context.mounted) return;
        if (result != null) {
          onItemSelected(result);
        }
      },
    );
  }
}

class _CustomSearchDelegate extends SearchDelegate<String?> {
  final List<String> searchHints;
  final List<String> searchTerms;

  _CustomSearchDelegate(this.searchHints, this.searchTerms);

  @override
  String? get searchFieldLabel =>
      'Search ${searchHints.map((e) => e.toLowerCase()).join(", ")}';

  List<String> _getMatchedResults() {
    return searchTerms
        .where((term) => term.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget _buildResultList(List<String> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          "No results found",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(title: Text(item), onTap: () => close(context, item));
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultList(_getMatchedResults());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultList(_getMatchedResults());
  }
}
