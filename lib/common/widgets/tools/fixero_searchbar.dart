import 'package:flutter/material.dart';

typedef SearchCallback = void Function(String selected);

class FixeroSearchBar extends StatefulWidget {
  final List<String> searchHints; // for placeholder text
  final List<String> searchTerms; // the items to search from
  final SearchCallback onItemSelected; // returns selected result
  final String hintPrefix;
  final void Function(String query)? onChanged;

  const FixeroSearchBar({
    super.key,
    required this.searchHints,
    required this.searchTerms,
    required this.onItemSelected,
    this.hintPrefix = "Search",
    this.onChanged,
  });

  @override
  State<FixeroSearchBar> createState() => _FixeroSearchBarState();
}

class _FixeroSearchBarState extends State<FixeroSearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<String> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _filteredResults = widget.searchTerms;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChangedInternal(String value) {
    setState(() {
      _filteredResults = widget.searchTerms
          .where((term) => term.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });

    // notify parent to filter list if callback provided
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  void _onItemTap(String value) {
    _controller.text = value;
    widget.onItemSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    final hintText =
        '${widget.hintPrefix} ${widget.searchHints.map((e) => e.toLowerCase()).join(", ")}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _onChangedInternal('');
                    },
                  )
                : null,
          ),
          onChanged: _onChangedInternal, // use this
        ),

        const SizedBox(height: 5),

        if (_controller.text.isNotEmpty)
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final item = _filteredResults[index];
                return ListTile(
                  title: Text(item),
                  onTap: () => _onItemTap(item),
                );
              },
            ),
          ),
      ],
    );
  }
}
