import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../controllers/manu_vehicles_controller.dart';
import '../models/vehicle.dart';
import 'vehicle_details_view.dart';
import 'car_models_view.dart' show VehicleFormDialog;

class ManufacturerVehiclesView extends StatefulWidget {
  static const String routeName = '/manufacturer_vehicles';
  final String manufacturer;

  const ManufacturerVehiclesView({super.key, required this.manufacturer});

  @override
  State<ManufacturerVehiclesView> createState() =>
      _ManufacturerVehiclesViewState();
}

class _ManufacturerVehiclesViewState extends State<ManufacturerVehiclesView> {
  late final ManufacturerVehiclesController controller;
  final _queryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ManufacturerVehiclesController(widget.manufacturer)..listen();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    controller.dispose();
    super.dispose();
  }

  // ───────────────────────────────── Info dialog ─────────────────────────────────
  void _showInfo() {
    final t = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 8),
            const Text('About this page'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '• Search cars by plate, owner, or model using the box below.',
            ),
            SizedBox(height: 6),
            Text('• Use “Sort By” to reorder by Plate, Owner, or Model.'),
            SizedBox(height: 6),
            Text('• Tap a car row to open its Car Overview.'),
            SizedBox(height: 6),
            Text(
              '• Use the Edit/Delete icons at the end of each row to update or remove a vehicle.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: TextStyle(color: t.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────── helpers ─────────────────────────────────
  Future<String?> _findKeyByPlate(String plateNo) async {
    final ref = FirebaseDatabase.instance.ref('vehicles');
    final d = await ref.child(plateNo).get();
    if (d.exists) return plateNo;
    final q = await ref.orderByChild('plateNo').equalTo(plateNo).get();
    if (q.exists) {
      for (final c in q.children) {
        return c.key;
      }
    }
    return null;
  }

  Future<void> _editVehicle(Vehicle original) async {
    final key = await _findKeyByPlate(original.plateNo);
    if (key == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle "${original.plateNo}" not found')),
      );
      return;
    }
    if (!mounted) return;
    final updated = await showDialog<Vehicle>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VehicleFormDialog(original: original),
    );
    if (updated != null) {
      final before = original.toMap();
      final after = updated.toMap();
      final diff = <String, dynamic>{};
      for (final k in after.keys) {
        if (after[k] != before[k]) diff[k] = after[k];
      }
      diff.remove('plateNo');
      await FirebaseDatabase.instance.ref('vehicles/$key').update(diff);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vehicle updated')));
    }
  }

  Future<void> _deleteVehicle(Vehicle v) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Delete "${v.plateNo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final key = await _findKeyByPlate(v.plateNo);
    if (key == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle "${v.plateNo}" not found')),
      );
      return;
    }
    await FirebaseDatabase.instance.ref('vehicles/$key').remove();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Vehicle deleted')));
  }

  Color _colorFromName(String? colorName, ThemeData t) {
    final s = (colorName ?? '').toLowerCase().trim();
    if (s.contains('red')) return Colors.red;
    if (s.contains('blue')) return Colors.blue;
    if (s.contains('green')) return Colors.green;
    if (s.contains('black')) return Colors.black87;
    if (s.contains('white')) return Colors.grey.shade400;
    if (s.contains('silver') || s.contains('grey') || s.contains('gray'))return Colors.grey;
    if (s.contains('yellow')) return Colors.yellow.shade700;
    if (s.contains('orange')) return Colors.orange;
    if (s.contains('purple')) return Colors.purple;
    if (s.contains('brown')) return Colors.brown;
    if (s.contains('gold')) return const Color(0xFFD4AF37);
    return t.colorScheme.primary;
  }

  // ─────────────────────────────────── UI ────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final headerColor = t.colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: const FixeroBottomAppBar(),
      appBar: AppBar(
        toolbarHeight: 105,
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x1A000000),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.manufacturer,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _queryCtrl,
                onChanged: controller.setQuery,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: 'Search vehicles',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
            child: Row(
              children: [
                Text('Sort By  ', style: t.textTheme.bodyMedium),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButton<VehicleSort>(
                    value: controller.sort,
                    isExpanded: false,
                    onChanged: (v) =>
                        controller.setSort(v ?? VehicleSort.plateAsc),
                    items: const [
                      DropdownMenuItem(
                        value: VehicleSort.plateAsc,
                        child: Text('Plate (A → Z)'),
                      ),
                      DropdownMenuItem(
                        value: VehicleSort.plateDesc,
                        child: Text('Plate (Z → A)'),
                      ),
                      DropdownMenuItem(
                        value: VehicleSort.ownerAsc,
                        child: Text('Owner (A → Z)'),
                      ),
                      DropdownMenuItem(
                        value: VehicleSort.ownerDesc,
                        child: Text('Owner (Z → A)'),
                      ),
                      DropdownMenuItem(
                        value: VehicleSort.modelAsc,
                        child: Text('Model (A → Z)'),
                      ),
                      DropdownMenuItem(
                        value: VehicleSort.modelDesc,
                        child: Text('Model (Z → A)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (ctx, _) {
                final items = controller.vehicles;
                if (items.isEmpty) {
                  return const Center(child: Text('No vehicles found'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final v = items[i];
                    final bubble = _colorFromName(v.colorName, t);
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                VehicleDetailsView(plateNo: v.plateNo),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            // colored bubble that represents the vehicle color
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: bubble.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: bubble.withValues(alpha: .65),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                size: 22,
                                color: bubble,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.plateNo,
                                    style: t.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_rounded,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        v.ownerName ?? 'Unknown Owner',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    v.model,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_note),
                              onPressed: () => _editVehicle(v),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteVehicle(v),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
