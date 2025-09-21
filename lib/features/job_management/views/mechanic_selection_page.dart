import 'package:flutter/material.dart';
import 'package:fixero/features/job_management/models/mechanic_model.dart';
import 'package:fixero/features/job_management/controllers/mechanic_controller.dart';
import 'package:fixero/features/job_management/models/job.dart';
import 'package:fixero/data/repositories/job_services/mechanic_repository.dart';
import 'package:fixero/common/widgets/bars/fixero_sub_appbar.dart';
import 'job_schedule_page.dart';

class MechanicSelectionPage extends StatefulWidget {
  final Job job;

  const MechanicSelectionPage({super.key, required this.job});

  @override
  State<MechanicSelectionPage> createState() => _MechanicSelectionPageState();
}

class _MechanicSelectionPageState extends State<MechanicSelectionPage> {
  final MechanicController _mechanicController = MechanicController(
    MechanicRepository(),
  );
  List<Mechanic> _mechanics = [];
  List<Mechanic> _filteredMechanics = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMechanics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMechanics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _mechanicController.loadMechanics();

      // Always sort A-Z by mechanicName
      _mechanics = _mechanicController.getAvailableMechanics()
        ..sort((a, b) => a.mechanicName.compareTo(b.mechanicName));

      _filteredMechanics = List.from(_mechanics);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load mechanics: $e';
        _isLoading = false;
      });
    }
  }

  void _filterMechanics(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMechanics = List.from(_mechanics);
      } else {
        _filteredMechanics = _mechanicController.searchMechanics(query)
          ..sort((a, b) => a.mechanicName.compareTo(b.mechanicName));
      }
    });
  }

  void _selectMechanic(Mechanic mechanic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SchedulePage(job: widget.job, selectedMechanic: mechanic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixeroSubAppBar(title: 'Select Mechanic', showBackButton: true),
      body: RefreshIndicator(
        onRefresh: _loadMechanics,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search mechanics by name or specialty',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: _filterMechanics,
              ),
            ),

            // Filter chips for specialties
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _getUniqueSpecialties().length,
                itemBuilder: (context, index) {
                  final specialty = _getUniqueSpecialties()[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(specialty),
                      onSelected: (selected) {
                        _filterMechanics(selected ? specialty : '');
                      },
                      selected: _searchQuery == specialty,
                    ),
                  );
                },
              ),
            ),

            // Mechanics list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _filteredMechanics.isEmpty
                  ? const Center(child: Text('No available mechanics found'))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredMechanics.length,
                      itemBuilder: (context, index) {
                        final mechanic = _filteredMechanics[index];
                        return _MechanicCard(
                          mechanic: mechanic,
                          onSelect: () => _selectMechanic(mechanic),
                          isSelected:
                              mechanic.mechanicID == widget.job.mechanicID,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getUniqueSpecialties() {
    final specialties = _mechanics
        .expand((mechanic) => mechanic.specialties)
        .toSet()
        .toList();
    specialties.sort();
    return specialties;
  }
}

class _MechanicCard extends StatelessWidget {
  final Mechanic mechanic;
  final VoidCallback onSelect;
  final bool isSelected;

  const _MechanicCard({
    required this.mechanic,
    required this.onSelect,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = mechanic.mechanicStatus.toLowerCase() == "available";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected ? Colors.blue[50] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            mechanic.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          mechanic.mechanicName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialty: ${mechanic.mechanicSpecialty}'),
            Text(
              'Status: ${mechanic.mechanicStatus}',
              style: TextStyle(
                color: isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Experience: ${mechanic.formattedJoinDate}'),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onSelect,
      ),
    );
  }
}
