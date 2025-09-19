import 'package:flutter/material.dart';
import '../../../features/CRM/views/customerRelationship_page.dart';
import '../../../features/inventory_management/views/inventory_page.dart';
import '../../../home_page.dart';
import '../../../features/vehicle_management/views/car_models_view.dart';


class FixeroBottomAppBar extends StatelessWidget {
  const FixeroBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;

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
            Expanded(child: _navItem(context, Icons.home, 'Home', theme, const HomePage(), HomePage.routeName, currentRoute)),
            Expanded(child: _navItem(context, Icons.work, 'Jobs', theme, const HomePage(), '/jobs', currentRoute)),
            Expanded(child: _navItem(context, Icons.directions_car, 'Vehicles', theme, const CarModelsView(), CarModelsView.routeName, currentRoute)),
            Expanded(child: _navItem(context, Icons.inventory, 'Inventory', theme, const InventoryPage(), InventoryPage.routeName, currentRoute)),
            Expanded(child: _navItem(context, Icons.people, 'CRM', theme, const CrmHomePage(), CrmHomePage.routeName, currentRoute)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context,
      IconData icon,
      String label,
      ThemeData theme,
      Widget page,
      String destinationRoute,
      String? currentRoute,
      ) {
    final isActive = destinationRoute == currentRoute;

    return TextButton(
      onPressed: () {
        if (!isActive) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => page,
              settings: RouteSettings(name: destinationRoute),
            ),
          );
        }
      },
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? theme.colorScheme.inversePrimary : theme.colorScheme.inversePrimary.withAlpha(120),
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? theme.colorScheme.inversePrimary : theme.colorScheme.inversePrimary.withAlpha(120),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}