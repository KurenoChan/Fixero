import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../controllers/car_models_controller.dart';
import '../models/car_model.dart';
import 'manu_vehicles_view.dart';

class CarModelsView extends StatefulWidget {
  static const String routeName = '/car_models';

  const CarModelsView({super.key});

  @override
  State<CarModelsView> createState() => _CarModelsViewState();
}

class _CarModelsViewState extends State<CarModelsView> {
  late final CarModelsController controller;

  @override
  void initState() {
    super.initState();
    controller = CarModelsController();
    _ensureFirebaseThenListen();
    controller.addListener(_onUpdate);
  }

  Future<void> _ensureFirebaseThenListen() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
    await controller.listenManufacturers(path: 'vehicles');
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
            // ── Header (rounded, dark, left-aligned with info button) ─────────
            Container(
              height: 105,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Car',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          final t = Theme.of(ctx);
                          return AlertDialog(
                            backgroundColor: t.colorScheme.surface,
                            title: Text(
                              'Vehicles Page',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: t.colorScheme.inversePrimary,
                              ),
                            ),
                            content: Text(
                              'This page shows a summary of vehicles grouped by manufacturer.\n\n'
                              '• Each box represents one manufacturer (e.g., Toyota, Honda).\n'
                              '• The number inside the box is how many vehicles of that manufacturer are stored in the database.\n'
                              '• Tap a box to see the list of vehicles for that manufacturer.\n\n'
                              'This helps the workshop manager quickly understand the distribution of vehicles.',
                              style: t.textTheme.bodyMedium?.copyWith(
                                color: t.colorScheme.onSurface,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: t.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Search field ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                onChanged: controller.setQuery,
                decoration: InputDecoration(
                  hintText: 'Search manufacturers',
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
            ),

            // ── Grid of manufacturer cards ─────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: controller.models.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.90,
                ),
                itemBuilder: (context, i) {
                  final CarModel m = controller.models[i];
                  return _CarCard(model: m);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarModel model;

  const _CarCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color tileBg = theme.colorScheme.primary.withValues(alpha: 0.35);
    final Color titleColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final Color countColor = theme.colorScheme.inversePrimary;

    return InkWell(
      onTap: () {
        // 🔑 Navigate to manufacturer-specific page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ManufacturerVehiclesView(manufacturer: model.name),
            settings: const RouteSettings(
              name: ManufacturerVehiclesView.routeName,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  model.imagePath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.low,
                  cacheWidth: 256,
                  cacheHeight: 256,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.directions_car, size: 64),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              model.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: titleColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                model.count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: countColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
