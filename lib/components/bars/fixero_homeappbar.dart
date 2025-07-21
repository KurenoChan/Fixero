import 'package:flutter/material.dart';

class FixeroHomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final String profileImgUrl;

  const FixeroHomeAppbar({
    super.key,
    required this.username,
    required this.profileImgUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 50); // Added height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top: 0.0), // top spacing
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT SIDE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.8),
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    username,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),

              // RIGHT SIDE
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(profileImgUrl),
                backgroundColor: Colors.grey[200],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
