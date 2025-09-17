import 'package:flutter/material.dart';
import '../../vehicle_management/controllers/vehicle_types_controller.dart';
import '../../vehicle_management/models/vehicle_type.dart';
import '../../../common/widgets/bars/fixero_bottom_appbar.dart';

class VehicleHomeView extends StatefulWidget {
  static const String routeName = '/vehicles';

  final void Function(BuildContext context, VehicleType type)? onSelectType;

  const VehicleHomeView({super.key, this.onSelectType});

  @override
  State<VehicleHomeView> createState() => _VehicleHomeViewState();
}

class _VehicleHomeViewState extends State<VehicleHomeView> {
  late final VehicleTypesController controller;

  @override
  void initState() {
    super.initState();
    controller = VehicleTypesController(
      onSelectType: (type) => widget.onSelectType?.call(context, type),
    );
    controller.addListener(_onControllerUpdated);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdated);
    controller.dispose();
    super.dispose();
  }

  void _onControllerUpdated() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final types = controller.filteredTypes;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const FixeroBottomAppBar(),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _VehiclesHeader(),

            // Content padding below header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  TextField(
                    onChanged: controller.setQuery,
                    decoration: InputDecoration(
                      hintText: 'Search vehicles',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),
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
                  const SizedBox(height: 20),

                  // Section header
                  Text(
                    'Types',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid of vehicle type cards
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: types.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.1,
                        ),
                    itemBuilder: (_, i) => _VehicleTypeCard(
                      type: types[i],
                      onTap: () => controller.selectType(types[i]),
                    ),
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

class _VehiclesHeader extends StatelessWidget {
  const _VehiclesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF424242),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Vehicles',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color.fromRGBO(224, 224, 224, 1),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final VehicleType type;
  final VoidCallback onTap;

  const _VehicleTypeCard({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(type.icon, size: 48, color: Colors.grey.shade700),
              const SizedBox(height: 12),
              Text(
                type.displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
