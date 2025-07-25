import 'package:flutter/material.dart';

class FixeroSearcher extends StatelessWidget {
  final List<String> searchHints;
  final List<String> searchTerms;

  const FixeroSearcher({
    super.key,
    required this.searchHints,
    required this.searchTerms,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search, color: Theme.of(context).primaryColor, size: 30),
      onPressed: () async {
        final localContext = context;

        final result = await showSearch(
          context: localContext,
          delegate: CustomSearchDelegate(searchHints, searchTerms),
        );

        if (!localContext.mounted) return;

        if (result != null) {
          ScaffoldMessenger.of(
            localContext,
          ).showSnackBar(SnackBar(content: Text('You selected: $result')));
        }
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<String> searchHint;
  final List<String> searchTerms;

  CustomSearchDelegate(this.searchHint, this.searchTerms);

  @override
  String? get searchFieldLabel => 'Search ${searchHint.map((e) => e.toLowerCase()).join(", ")}, etc.';

  List<String> _getMatchedResults() {
    return searchTerms
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget _buildResultList(List<String> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result); // return the selected value
          },
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
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
