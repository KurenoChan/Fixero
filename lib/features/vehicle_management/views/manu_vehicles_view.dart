import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../controllers/manu_vehicles_controller.dart';
import '../models/vehicle.dart';

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

  @override
  void initState() {
    super.initState();
    controller = ManufacturerVehiclesController(widget.manufacturer);
    _ensureFirebaseThenListen();
    controller.addListener(_onUpdate);
  }

  Future<void> _ensureFirebaseThenListen() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
    await controller.listen();
  }

  @override
  void dispose() {
    controller.removeListener(_onUpdate);
    controller.dispose();
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inverse = theme.colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: const FixeroBottomAppBar(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              height: 84,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              decoration: BoxDecoration(
                color: inverse,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.manufacturer,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () => _showInfoDialog(context),
                  ),
                ],
              ),
            ),

            // Search + Sort
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  TextField(
                    onChanged: controller.setQuery,
                    decoration: InputDecoration(
                      hintText: 'Search vehicles',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        'Sort By',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_vert_rounded),
                        onPressed: controller.toggleSort,
                        tooltip: 'Toggle sort',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: controller.vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) =>
                    _VehicleTile(v: controller.vehicles[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final t = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.colorScheme.surface,
        title: Text(
          '${widget.manufacturer} Vehicles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: t.colorScheme.inversePrimary,
          ),
        ),
        content: Text(
          'This page lists all vehicles for the selected manufacturer.\n\n'
          '• Left colored circle reflects vehicle color.\n'
          '• Bold text is the plate number.\n'
          '• Next line shows owner name (gender icon).\n'
          '• Last line shows the model.',
          style: t.textTheme.bodyMedium?.copyWith(
            color: t.colorScheme.onSurface,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: t.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.v});
  final Vehicle v;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    final circleColor = ManufacturerVehiclesController.colorFromName(
      v.colorName,
    );
    final genderIcon = (v.ownerGender == 'female')
        ? Icons.female
        : (v.ownerGender == 'male' ? Icons.male : Icons.person);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VehicleDetailsView(vehicle: v)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // color circle + car icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor.withOpacity(0.35),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car,
                  size: 22,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plate number (bold)
                  Text(
                    v.plateNo.isEmpty ? 'Unknown Plate' : v.plateNo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Owner row
                  Row(
                    children: [
                      Icon(genderIcon, size: 18, color: Colors.black87),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          v.ownerName?.isNotEmpty == true
                              ? v.ownerName!
                              : 'Unknown Owner',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Model
                  Text(
                    v.model,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple placeholder so tapping a row navigates somewhere
class VehicleDetailsView extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleDetailsView({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vehicle ${vehicle.plateNo}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Details screen placeholder for ${vehicle.manufacturer} ${vehicle.model}.',
        ),
      ),
    );
  }
}
