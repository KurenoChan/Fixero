import 'package:flutter/material.dart';

import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../controllers/car_models_controller.dart';
import '../models/car_model.dart';
import '../models/vehicle.dart';
import 'manu_vehicles_view.dart';

class CarModelsView extends StatefulWidget {
  static const String routeName = '/car_models';

  const CarModelsView({super.key});

  @override
  State<CarModelsView> createState() => _CarModelsViewState();
}

class _CarModelsViewState extends State<CarModelsView> {
  late final CarModelsController controller;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = CarModelsController();
    controller.listenManufacturers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    final created = await showDialog<Vehicle>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const VehicleFormDialog(),
    );
    if (created != null) {
      await controller.createVehicle(created, keyAsPlate: true);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vehicle added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final headerColor = theme.colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: const FixeroBottomAppBar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 105,
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x1A000000),
        centerTitle: true,
        title: const Text(
          'Vehicles',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search + Add row below the AppBar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
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
                      controller: _searchCtrl,
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
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _openAdd,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),

          // Manufacturer grid
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (ctx, _) {
                final list = controller.models;
                if (list.isEmpty) {
                  return const Center(child: Text('No vehicles yet'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final m = list[i];
                    return _ManufacturerCard(
                      model: m,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ManufacturerVehiclesView(manufacturer: m.name),
                          ),
                        );
                      },
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

// ───────────────────────── Manufacturer card ─────────────────────────
class _ManufacturerCard extends StatelessWidget {
  final CarModel model;
  final VoidCallback onTap;
  const _ManufacturerCard({required this.model, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: cs.surface,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(model.imagePath, height: 72, fit: BoxFit.contain),
              const SizedBox(height: 12),
              Text(model.name, style: t.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('${model.count} vehicles', style: t.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────── Add Vehicle Form (overflow-safe, extended fields) ───────────
class VehicleFormDialog extends StatefulWidget {
  final Vehicle? original; // null => create

  const VehicleFormDialog({super.key, this.original});

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController plateCtrl;
  late final TextEditingController manuCtrl;
  late final TextEditingController modelCtrl;
  late final TextEditingController typeCtrl;
  late final TextEditingController colorCtrl;
  late final TextEditingController yearCtrl;
  late final TextEditingController ownerIdCtrl;
  late final TextEditingController imageCtrl;

  // Extra specs
  late final TextEditingController vinCtrl;
  late final TextEditingController makeCtrl;
  late final TextEditingController powerCtrl;
  late final TextEditingController limiterCtrl;
  late final TextEditingController mileageCtrl;
  late final TextEditingController tankCtrl;

  @override
  void initState() {
    super.initState();
    final v = widget.original;
    plateCtrl = TextEditingController(text: v?.plateNo ?? '');
    manuCtrl = TextEditingController(text: v?.manufacturer ?? '');
    modelCtrl = TextEditingController(text: v?.model ?? '');
    typeCtrl = TextEditingController(text: v?.type ?? '');
    colorCtrl = TextEditingController(text: v?.colorName ?? '');
    yearCtrl = TextEditingController(
      text: v?.year == null ? '' : v!.year.toString(),
    );
    ownerIdCtrl = TextEditingController(text: v?.ownerId ?? '');
    imageCtrl = TextEditingController(text: v?.imageUrl ?? '');

    vinCtrl = TextEditingController(text: v?.vin ?? '');
    makeCtrl = TextEditingController(text: v?.make ?? '');
    powerCtrl = TextEditingController(text: v?.peakPowerKw?.toString() ?? '');
    limiterCtrl = TextEditingController(
      text: v?.speedLimiter?.toString() ?? '',
    );
    mileageCtrl = TextEditingController(text: v?.mileage?.toString() ?? '');
    tankCtrl = TextEditingController(text: v?.fuelTank?.toString() ?? '');
  }

  @override
  void dispose() {
    plateCtrl.dispose();
    manuCtrl.dispose();
    modelCtrl.dispose();
    typeCtrl.dispose();
    colorCtrl.dispose();
    yearCtrl.dispose();
    ownerIdCtrl.dispose();
    imageCtrl.dispose();
    vinCtrl.dispose();
    makeCtrl.dispose();
    powerCtrl.dispose();
    limiterCtrl.dispose();
    mileageCtrl.dispose();
    tankCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.original != null;
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = MediaQuery.of(context).size.height * .82;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH, minWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(isEdit ? Icons.edit : Icons.add_circle_outline),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? 'Edit Vehicle' : 'Add Vehicle',
                        style: t.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: Form(
                    key: _form,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicle Information',
                              style: t.textTheme.titleMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _field(
                              controller: plateCtrl,
                              label: 'Plate No *',
                              readOnly: isEdit,
                              capitalization: TextCapitalization.characters,
                              validator: _req,
                            ),
                            _field(
                              controller: manuCtrl,
                              label: 'Manufacturer *',
                              validator: _req,
                            ),
                            _field(
                              controller: modelCtrl,
                              label: 'Model *',
                              validator: _req,
                            ),
                            _field(
                              controller: typeCtrl,
                              label: 'Type (e.g. Sedan) *',
                              validator: _req,
                            ),
                            _field(
                              controller: colorCtrl,
                              label: 'Color Name *',
                              validator: _req,
                            ),
                            _field(
                              controller: yearCtrl,
                              label: 'Year *',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n <= 0) {
                                  return 'Enter valid year';
                                }
                                return null;
                              },
                            ),
                            _field(
                              controller: ownerIdCtrl,
                              label: 'Owner ID *',
                              validator: _req,
                            ),
                            _field(controller: imageCtrl, label: 'Image URL'),

                            const SizedBox(height: 12),
                            Text(
                              'Specs',
                              style: t.textTheme.titleMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _field(controller: vinCtrl, label: 'VIN'),
                            _field(controller: makeCtrl, label: 'Make'),
                            _numField(
                              controller: powerCtrl,
                              label: 'Peak Power (kW)',
                            ),
                            _numField(
                              controller: limiterCtrl,
                              label: 'Speed Limiter (km/h)',
                            ),
                            _numField(
                              controller: mileageCtrl,
                              label: 'Mileage (KM)',
                            ),
                            _numField(
                              controller: tankCtrl,
                              label: 'Fuel Tank (L)',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          if (!_form.currentState!.validate()) return;

                          int? _toInt(String s) =>
                              s.trim().isEmpty ? null : int.tryParse(s.trim());

                          final v = Vehicle(
                            plateNo: plateCtrl.text.trim().toUpperCase(),
                            manufacturer: manuCtrl.text.trim(),
                            model: modelCtrl.text.trim(),
                            type: typeCtrl.text.trim(),
                            colorName: colorCtrl.text.trim(),
                            year: int.parse(yearCtrl.text.trim()),
                            ownerId: ownerIdCtrl.text.trim(),
                            imageUrl: imageCtrl.text.trim().isEmpty
                                ? null
                                : imageCtrl.text.trim(),
                            // specs
                            vin: vinCtrl.text.trim().isEmpty
                                ? null
                                : vinCtrl.text.trim(),
                            make: makeCtrl.text.trim().isEmpty
                                ? null
                                : makeCtrl.text.trim(),
                            peakPowerKw: _toInt(powerCtrl.text),
                            speedLimiter: _toInt(limiterCtrl.text),
                            mileage: _toInt(mileageCtrl.text),
                            fuelTank: _toInt(tankCtrl.text),
                            // keep existing owner
                            ownerName: widget.original?.ownerName,
                            ownerGender: widget.original?.ownerGender,
                          );

                          Navigator.pop(context, v);
                        },
                        child: Text(isEdit ? 'Save' : 'Add'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // helpers
  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextCapitalization capitalization = TextCapitalization.none,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        textCapitalization: capitalization,
        validator: validator,
        keyboardType: keyboardType,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ).copyWith(labelText: label),
      ),
    );
  }

  Widget _numField({
    required TextEditingController controller,
    required String label,
  }) {
    return _field(
      controller: controller,
      label: label,
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        return int.tryParse(v.trim()) == null ? 'Enter a number' : null;
      },
    );
  }
}
