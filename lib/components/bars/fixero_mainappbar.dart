import 'package:fixero/components/bars/fixero_searcher.dart';
import 'package:fixero/utils/formatter.dart';
import 'package:flutter/material.dart';

class FixeroMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<String> searchHints;
  final List<String> searchTerms;

  const FixeroMainAppBar({
    super.key,
    required this.title,
    required this.searchHints,
    required this.searchTerms,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 50); // Added height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top: 0.0), // top spacing
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 35),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT SIDE
              Text(
                // capitalize
                Formatter.capitalize(title),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),

              // RIGHT SIDE
              FixeroSearcher(
                searchHints: searchHints,
                searchTerms: searchTerms,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
