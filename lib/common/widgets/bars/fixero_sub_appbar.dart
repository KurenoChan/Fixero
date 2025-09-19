import 'package:flutter/material.dart';

class FixeroSubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const FixeroSubAppBar({
    super.key,
    required this.title,
    required this.showBackButton,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20); // Added height

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.inversePrimary,
      elevation: 0,
      toolbarHeight: 150,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.onPrimary,
                size: 30,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 25,
        ),
      ),

      actions: [const SizedBox(width: 45)],

      centerTitle: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }
}
