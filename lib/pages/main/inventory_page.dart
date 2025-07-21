import 'package:fixero/components/bars/fixero_bottomappbar.dart';
import 'package:fixero/components/bars/fixero_mainappbar.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  static const routeName = '/inventory';

  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: FixeroMainAppBar(title: "Inventory"),
      
        bottomNavigationBar: FixeroBottomAppBar(),
      ),
    );
  }
}
