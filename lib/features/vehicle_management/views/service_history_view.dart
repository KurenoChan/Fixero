import 'package:flutter/material.dart';
import '../controllers/service_history_controller.dart';
import '../models/service_job.dart';

class ServiceHistoryView extends StatefulWidget {
  const ServiceHistoryView({super.key, required this.plateNo});
  final String plateNo;

  @override
  State<ServiceHistoryView> createState() => _ServiceHistoryViewState();
}

class _ServiceHistoryViewState extends State<ServiceHistoryView> {
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
    Theme.of(context);
    final jobs = controller.allSorted;

    return Scaffold(
      appBar: AppBar(title: Text('Service History — ${widget.plateNo}')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        itemCount: jobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _JobCard(job: jobs[i]),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final ServiceJob job;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDone = job.jobStatus.toLowerCase() == 'completed';
    final statusColor = isDone ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: t.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            children: [
              Expanded(
                child: Text(
                  job.jobServiceType.isEmpty ? 'Service' : job.jobServiceType,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.jobStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.event,
                size: 16,
                color: t.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                '${job.scheduledDate}  •  ${job.scheduledTime}',
                style: t.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (job.jobDescription.isNotEmpty)
            Text(job.jobDescription, style: t.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(t, 'Plate', job.plateNo),
              if (job.estimatedDuration != null)
                _chip(t, 'Duration', '${job.estimatedDuration}h'),
              if ((job.managedBy ?? '').isNotEmpty)
                _chip(t, 'Managed By', job.managedBy!),
              if ((job.mechanicID ?? '').isNotEmpty)
                _chip(t, 'Mechanic', job.mechanicID!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(ThemeData t, String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$k: $v',
        style: TextStyle(
          color: t.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
