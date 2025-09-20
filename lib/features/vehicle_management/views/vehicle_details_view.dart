import 'package:flutter/material.dart';

import '../../../common/widgets/bars/fixero_bottom_appbar.dart';
import '../controllers/vehicle_details_controller.dart';
import '../controllers/service_history_controller.dart';
import '../models/vehicle.dart';
import '../models/service_job.dart';

class VehicleDetailsView extends StatefulWidget {
  static const routeName = '/vehicle_details';

  const VehicleDetailsView({
    super.key,
    required this.plateNo,
    this.initialVehicle,
  });

  final String plateNo;
  final Vehicle? initialVehicle;

  @override
  State<VehicleDetailsView> createState() => _VehicleDetailsViewState();
}

class _VehicleDetailsViewState extends State<VehicleDetailsView> {
  late final VehicleDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = VehicleDetailsController(
      plateNo: widget.plateNo,
      initialVehicle: widget.initialVehicle,
    )..addListener(_onUpdate);
    controller.listen();
  }

  void _onUpdate() => setState(() {});
  @override
  void dispose() {
    controller.removeListener(_onUpdate);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerColor = theme.colorScheme.inversePrimary;
    final v = controller.vehicle;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

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
        title: const Text(
          'Car Overview',
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

      bottomNavigationBar: const FixeroBottomAppBar(),

      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : v == null
          ? const Center(child: Text('Vehicle not found'))
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 12),
                _wideHero(imageUrl: v.imageUrl),

                // Title card (model + plate + owner)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: _TitleCard(vehicle: v),
                ),

                const SizedBox(height: 16),

                // Spec tiles (yellow icons, distinct per metric)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      _StatTile(
                        icon: Icons.bolt, // Peak power
                        value: _fmtInt(v.peakPowerKw),
                        label: 'kW',
                      ),
                      _StatTile(
                        icon: Icons.speed, // Speed limiter
                        value: _fmtInt(v.speedLimiter),
                        label: 'km/h',
                      ),
                      _StatTile(
                        icon: Icons.alt_route_rounded, // Mileage
                        value: _fmtInt(v.mileage),
                        label: 'KM',
                      ),
                      _StatTile(
                        icon: Icons.local_gas_station_rounded, // Fuel tank
                        value: _fmtInt(v.fuelTank),
                        label: 'Litres',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Vehicle details card
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                  child: _VehicleDetailsCard(vehicle: v),
                ),

                // Recent Service History (latest 3) + CTA to full list
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  child: _RecentServiceHistorySection(plateNo: widget.plateNo),
                ),
              ],
            ),
    );
  }

  static String _fmtInt(int? n) => (n == null) ? '—' : n.toString();
}

Widget _wideHero({String? imageUrl}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  )
                : Container(
                    color: theme.colorScheme.surface,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.directions_car,
                      size: 96,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
          ),
        ),
      );
    },
  );
}

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final hasOwner = (vehicle.ownerName ?? '').isNotEmpty;
    final genderIcon = (vehicle.ownerGender == 'female')
        ? Icons.female
        : (vehicle.ownerGender == 'male' ? Icons.male : Icons.person);

    final plateChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: t.colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        vehicle.plateNo.isEmpty ? '—' : vehicle.plateNo,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );

    final ownerPill = hasOwner
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: t.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(genderIcon, size: 16, color: t.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  vehicle.ownerName!,
                  style: TextStyle(
                    color: t.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            vehicle.model.isEmpty
                ? '${vehicle.manufacturer} Vehicle'
                : vehicle.model,
            textAlign: TextAlign.center,
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: t.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              plateChip,
              if (hasOwner) const SizedBox(width: 10),
              if (hasOwner) ownerPill,
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  static const Color _kIconYellow = Color(0xFFF5C542);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final bg = t.colorScheme.primary;
    final on = t.colorScheme.onPrimary;

    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _kIconYellow, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: on,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: on.withValues(alpha: 0.85), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDetailsCard extends StatelessWidget {
  const _VehicleDetailsCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    Widget chip(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: t.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );

    Widget row(IconData icon, String label, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.dividerColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: t.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: t.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: t.textTheme.labelMedium?.copyWith(
                      color: t.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isEmpty ? '—' : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.titleSmall?.copyWith(
                      color: t.colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Vehicle Details',
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: t.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (vehicle.manufacturer.isNotEmpty) chip(vehicle.manufacturer),
              if (vehicle.type.isNotEmpty) const SizedBox(width: 6),
              if (vehicle.type.isNotEmpty) chip(vehicle.type),
            ],
          ),
          const SizedBox(height: 12),
          row(Icons.public_rounded, 'Made By', vehicle.make ?? ''),
          const SizedBox(height: 10),
          row(Icons.directions_car_filled_rounded, 'Car Model', vehicle.model),
          const SizedBox(height: 10),
          row(
            Icons.calendar_today_rounded,
            'Manufacture Year',
            vehicle.year == 0 ? '' : vehicle.year.toString(),
          ),
          const SizedBox(height: 10),
          row(
            Icons.confirmation_number_rounded,
            'Vehicle Identification Number (VIN)',
            vehicle.vin ?? '',
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// Recent Service History (latest 3) + "View Full History of Services"
/// ─────────────────────────────────────────────────────────────────────────
class _RecentServiceHistorySection extends StatefulWidget {
  const _RecentServiceHistorySection({required this.plateNo});
  final String plateNo;

  @override
  State<_RecentServiceHistorySection> createState() =>
      _RecentServiceHistorySectionState();
}

class _RecentServiceHistorySectionState
    extends State<_RecentServiceHistorySection> {
  late final ServiceHistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = ServiceHistoryController(widget.plateNo)
      ..addListener(_onUpdate);
    controller.listen();
  }

  void _onUpdate() => setState(() {});
  @override
  void dispose() {
    controller.removeListener(_onUpdate);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    // Newest → oldest
    final List<ServiceJob> recent = controller.allSorted.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Service History',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: t.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -3,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        _FullServiceHistoryView(plateNo: widget.plateNo),
                  ),
                );
              },
              child: const Text(
                'View Full History of Services',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: t.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.dividerColor),
            ),
            child: Text(
              'No service history found.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium,
            ),
          )
        else
          Column(children: [for (final job in recent) _ServiceTile(job: job)]),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.job});
  final ServiceJob job;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vis = _statusIcon(job.jobStatus, t);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: vis.color.withValues(alpha: 0.15),
          child: Icon(vis.icon, color: vis.color),
        ),
        title: Text(
          job.jobServiceType.isEmpty ? 'Service' : job.jobServiceType,
          style: t.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: t.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            _previewSubtitle(job),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
        trailing: _statusChip(job.jobStatus, t),
      ),
    );
  }

  static _StatusVisual _statusIcon(String status, ThemeData t) {
    final s = status.toLowerCase();
    if (s.contains('cancel')) {
      return _StatusVisual(Icons.cancel, Colors.redAccent);
    } else if (s.contains('complete') || s.contains('done')) {
      return _StatusVisual(Icons.check_circle, Colors.green);
    } else if (s.contains('progress')) {
      return _StatusVisual(Icons.build_circle, t.colorScheme.primary);
    } else if (s.contains('schedule') || s.contains('pending')) {
      return _StatusVisual(Icons.schedule, t.colorScheme.primary);
    }
    return _StatusVisual(Icons.info, t.colorScheme.secondary);
  }

  static Widget _statusChip(String status, ThemeData t) {
    final vis = _statusIcon(status, t);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: vis.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: vis.color.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(vis.icon, size: 14, color: vis.color),
          const SizedBox(width: 6),
          Text(
            _labelize(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: vis.color,
            ),
          ),
        ],
      ),
    );
  }

  static String _previewSubtitle(ServiceJob job) {
    final dt = job.sortStamp;
    final date =
        '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
    final desc = job.jobDescription.trim();
    if (desc.isEmpty) return date;
    return '$date • $desc';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _labelize(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return 'Unknown';
    final parts = s.replaceAll('-', ' ').replaceAll('_', ' ').split(' ');
    return parts
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _StatusVisual {
  const _StatusVisual(this.icon, this.color);
  final IconData icon;
  final Color color;
}

/// Full page for complete history list
class _FullServiceHistoryView extends StatefulWidget {
  const _FullServiceHistoryView({required this.plateNo});
  final String plateNo;

  @override
  State<_FullServiceHistoryView> createState() =>
      _FullServiceHistoryViewState();
}

class _FullServiceHistoryViewState extends State<_FullServiceHistoryView> {
  late final ServiceHistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = ServiceHistoryController(widget.plateNo)
      ..addListener(_onUpdate);
    controller.listen();
  }

  void _onUpdate() => setState(() {});
  @override
  void dispose() {
    controller.removeListener(_onUpdate);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final headerColor = t.colorScheme.inversePrimary;
    final List<ServiceJob> items = controller.allSorted;

    return Scaffold(
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
        title: const Text(
          'Full Service History',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
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
      body: items.isEmpty
          ? Center(
              child: Text('No services found.', style: t.textTheme.bodyMedium),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              itemCount: items.length,
              itemBuilder: (_, i) => _ServiceDetailCard(job: items[i]),
            ),
    );
  }
}

// ─────────────────────────── Detailed card widget ───────────────────────────

class _ServiceDetailCard extends StatefulWidget {
  const _ServiceDetailCard({required this.job});
  final ServiceJob job;

  @override
  State<_ServiceDetailCard> createState() => _ServiceDetailCardState();
}

class _ServiceDetailCardState extends State<_ServiceDetailCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final j = widget.job;
    final vis = _ServiceTile._statusIcon(j.jobStatus, t);

    final header = Row(
      children: [
        CircleAvatar(
          backgroundColor: vis.color.withValues(alpha: 0.15),
          child: Icon(vis.icon, color: vis.color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                j.jobServiceType.isEmpty ? 'Service' : j.jobServiceType,
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: t.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _ServiceTile._previewSubtitle(j),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _ServiceTile._statusChip(j.jobStatus, t),
      ],
    );

    Widget row(String label, String value) {
      return Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    final dt = j.sortStamp;
    final dateStr =
        '${dt.year}-${_ServiceTile._two(dt.month)}-${_ServiceTile._two(dt.day)}';
    final timeStr =
        '${_ServiceTile._two(dt.hour)}:${_ServiceTile._two(dt.minute)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          header,
          const SizedBox(height: 8),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4),
              child: Column(
                children: [
                  const Divider(height: 18),
                  row('Job ID', j.jobID),
                  const SizedBox(height: 6),
                  row('Plate No', j.plateNo),
                  const SizedBox(height: 6),
                  row(
                    'Scheduled Date',
                    j.scheduledDate.isEmpty ? dateStr : j.scheduledDate,
                  ),
                  const SizedBox(height: 6),
                  row(
                    'Scheduled Time',
                    j.scheduledTime.isEmpty ? timeStr : j.scheduledTime,
                  ),
                  const SizedBox(height: 6),
                  row(
                    'Estimated Duration',
                    j.estimatedDuration == null
                        ? '—'
                        : '${j.estimatedDuration} hour(s)',
                  ),
                  const SizedBox(height: 6),
                  row('Managed By', j.managedBy ?? '—'),
                  const SizedBox(height: 6),
                  row('Mechanic ID', j.mechanicID ?? '—'),
                  const SizedBox(height: 6),
                  row('Status', _ServiceTile._labelize(j.jobStatus)),
                  const SizedBox(height: 6),
                  row('Description', j.jobDescription.trim()),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -2,
                ),
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(_expanded ? 'Hide details' : 'Show details'),
            ),
          ),
        ],
      ),
    );
  }
}
