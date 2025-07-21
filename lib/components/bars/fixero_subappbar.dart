import 'package:fixero/utils/formatter.dart';
import 'package:flutter/material.dart';

class FixeroSubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const FixeroSubAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 50); // Added height

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.inversePrimary,
      elevation: 0,
      toolbarHeight: 150,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: theme.primaryColor, size: 30),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        // capitalize
        Formatter.capitalize(title),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 30,
        ),
      ),

      centerTitle: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),

      // flexibleSpace: Padding(
      //   padding: const EdgeInsets.only(top: 0.0), // top spacing
      //   child: Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      //     decoration: BoxDecoration(
      //       color: Theme.of(context).colorScheme.inversePrimary,
      //       borderRadius: BorderRadius.only(
      //         bottomLeft: Radius.circular(20),
      //         bottomRight: Radius.circular(20),
      //       ),
      //     ),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         // LEFT SIDE
      //         IconButton(
      //           icon: Icon(
      //             Icons.chevron_left,
      //             color: theme.primaryColor,
      //             size: 30,
      //           ),
      //           onPressed: () => Navigator.of(context).pop(),
      //         ),
      //
      //         Text(
      //           // capitalize
      //           Formatter.capitalize(title),
      //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
      //             color: Theme.of(context).colorScheme.primary,
      //             fontWeight: FontWeight.bold,
      //             fontSize: 30,
      //           ),
      //         ),
      //
      //         // RIGHT SIDE
      //         const SizedBox(width: 50),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
