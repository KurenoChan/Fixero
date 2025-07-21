import 'package:flutter/material.dart';

class FixeroAppbar extends StatelessWidget {
  final String title;

  const FixeroAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(title),
      centerTitle: true,
    );
  }
}
