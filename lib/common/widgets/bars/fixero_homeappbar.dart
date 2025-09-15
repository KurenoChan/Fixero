import 'package:fixero/features/authentication/controllers/auth_handler.dart';
import 'package:flutter/material.dart';

class FixeroHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final String profileImgUrl;

  const FixeroHomeAppBar({
    super.key,
    required this.username,
    required this.profileImgUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 50);

  /// Shows the confirmation dialog
  Future<void> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text("Log Out"),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!context.mounted) return;
      await AuthHandler.handleSignOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT: Welcome + Username
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
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

              // RIGHT: Profile Avatar + Dropdown Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _confirmLogout(context);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem<String>(
                    value: 'logout', // must match onSelected
                    child: Text('Log Out'),
                  ),
                ],
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(profileImgUrl),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
