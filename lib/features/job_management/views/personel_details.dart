import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fixero/features/job_management/controllers/mechanic_controller.dart';
import 'package:fixero/features/job_management/controllers/manager_controller.dart';

class PersonnelDetailsPage extends StatefulWidget {
  final String managerId;
  final String mechanicId;

  const PersonnelDetailsPage({
    super.key,
    required this.managerId,
    required this.mechanicId,
  });

  @override
  State<PersonnelDetailsPage> createState() => _PersonnelDetailsPageState();
}

class _PersonnelDetailsPageState extends State<PersonnelDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mechanicController = Provider.of<MechanicController>(
        context,
        listen: false,
      );
      final managerController = Provider.of<ManagerController>(
        context,
        listen: false,
      );

      mechanicController.loadMechanicById(widget.mechanicId);
      managerController.loadManagerById(widget.managerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MechanicController, ManagerController>(
      builder: (context, mechanicController, managerController, _) {
        final mechanic = mechanicController.getMechanicById(widget.mechanicId);
        final manager = managerController.getManagerById(widget.managerId);

        return Scaffold(
          appBar: AppBar(title: const Text('Personnel Details')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Mechanic Section
                _buildCard(
                  title: 'Mechanic Details',
                  isLoading: mechanicController.isLoading,
                  children: [
                    _DetailRow(
                      label: 'Mechanic ID',
                      value: mechanic?.mechanicID ?? 'Loading...',
                    ),
                    _DetailRow(
                      label: 'Name',
                      value: mechanic?.mechanicName ?? 'Loading...',
                    ),
                    _DetailRow(
                      label: 'Email',
                      value: mechanic?.mechanicEmail ?? 'Loading...',
                    ),
                    _DetailRow(
                      label: 'Specialty',
                      value: mechanic?.mechanicSpecialty ?? 'Loading...',
                    ),
                    _DetailRow(
                      label: 'Status',
                      value: mechanic?.mechanicStatus ?? 'Loading...',
                      valueColor: _getStatusColor(mechanic?.mechanicStatus),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Manager Section
                _buildCard(
                  title: 'Manager Details',
                  isLoading: managerController.isLoading,
                  children: [
                    _DetailRow(
                      label: 'Manager ID',
                      value: manager?.uid ?? 'Loading...',
                    ),
                    _DetailRow(
                      label: 'Name',
                      value: manager?.managerName ?? 'Loading...',
                    ),
                    _DetailRow(
                      label: 'Email',
                      value: manager?.managerEmail ?? 'Loading...',
                    ),
                    _DetailRow(
                      label: 'Role',
                      value: manager?.managerRole ?? 'Loading...',
                    ),
                  ],
                ),

                if (managerController.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      managerController.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required bool isLoading,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(children: children),
          ],
        ),
      ),
    );
  }

  Color? _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'off':
        return Colors.grey;
      default:
        return null;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
