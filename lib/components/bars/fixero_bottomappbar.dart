import 'package:flutter/material.dart';

class FixeroBottomAppBar extends StatelessWidget {
  const FixeroBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BottomAppBar(
        height: 80,
        color: theme.colorScheme.inversePrimary.withAlpha(50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, 'Home', theme),
            _navItem(Icons.work, 'Jobs', theme),
            _navItem(Icons.directions_car, 'Vehicles', theme),
            _navItem(Icons.inventory, 'Inventory', theme),
            _navItem(Icons.settings, 'Settings', theme),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, ThemeData theme) {
    return Expanded(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.inversePrimary, size: 24), // Not too big
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.inversePrimary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
