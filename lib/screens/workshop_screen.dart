import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workshop_provider.dart';
import '../models/workshop.dart';

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _showFilterSheet(BuildContext context) {
    final provider = context.read<WorkshopProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final colorScheme = Theme.of(context).colorScheme;
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          setModalState(() {});
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                  RadioListTile<WorkshopSort>(
                    title: const Text('Date: Newest'),
                    value: WorkshopSort.dateNewest,
                    groupValue: provider.currentSort,
                    onChanged: (val) {
                      provider.setSort(val!);
                      setModalState(() {});
                    },
                  ),
                  RadioListTile<WorkshopSort>(
                    title: const Text('Date: Oldest'),
                    value: WorkshopSort.dateOldest,
                    groupValue: provider.currentSort,
                    onChanged: (val) {
                      provider.setSort(val!);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: WorkshopStatus.values.map((status) {
                      final isSelected = provider.statusFilter == status;
                      return ChoiceChip(
                        label: Text(status.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.setStatusFilter(selected ? status : null);
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Location Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: LocationMode.values.map((mode) {
                      final isSelected = provider.locationFilter == mode;
                      return ChoiceChip(
                        label: Text(mode.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.setLocationFilter(selected ? mode : null);
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleController = TextEditingController();
    final participantsController = TextEditingController();
    final durationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    LocationMode selectedMode = LocationMode.virtual;
    DurationUnit selectedUnit = DurationUnit.minutes;
    String workshopType = 'design-thinking';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Workshop'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LocationMode>(
                      value: selectedMode,
                      decoration: const InputDecoration(labelText: 'Location Mode'),
                      items: LocationMode.values.map((mode) {
                        return DropdownMenuItem(value: mode, child: Text(mode.label));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedMode = val!),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: workshopType),
                      decoration: const InputDecoration(labelText: 'Workshop Type'),
                      onChanged: (val) => workshopType = val,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Duration'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<DurationUnit>(
                            value: selectedUnit,
                            items: DurationUnit.values.map((unit) {
                              return DropdownMenuItem(value: unit, child: Text(unit.label));
                            }).toList(),
                            onChanged: (val) => setDialogState(() => selectedUnit = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: participantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Participants'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final workshop = Workshop(
                      id: '',
                      title: titleController.text,
                      locationMode: selectedMode,
                      workshopType: workshopType,
                      status: WorkshopStatus.planned,
                      date: selectedDate,
                      durationValue: int.tryParse(durationController.text) ?? 0,
                      durationUnit: selectedUnit,
                      participantCount: int.tryParse(participantsController.text) ?? 0,
                    );
                    context.read<WorkshopProvider>().addWorkshop(workshop);
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLANNER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Text(
                      'WORKSHOP SESSIONS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.tune),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () => _showFilterSheet(context),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sessions...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) {
                // Implement search if needed in provider
              },
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: Consumer<WorkshopProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.workshops.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final workshops = provider.workshops;
                if (workshops.isEmpty) {
                  return _buildEmptyState(context);
                }

                final now = DateTime.now();
                final planned = workshops.where((w) => w.date.isAfter(now)).toList();
                final done = workshops.where((w) => w.date.isBefore(now)).toList();

                return ListView(
                  children: [
                    if (planned.isNotEmpty) ...[
                      _buildSectionHeader(context, 'PLANNED'),
                      ...planned.map((w) => _buildWorkshopItem(context, w)),
                    ],
                    if (done.isNotEmpty) ...[
                      _buildSectionHeader(context, 'DONE'),
                      ...done.map((w) => _buildWorkshopItem(context, w)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildWorkshopItem(BuildContext context, Workshop workshop) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPlanned = workshop.date.isAfter(DateTime.now());

    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (workshop.locationMode) {
      case LocationMode.virtual:
        icon = Icons.videocam;
        iconBg = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        break;
      case LocationMode.onSite:
        icon = Icons.person;
        iconBg = colorScheme.tertiaryContainer;
        iconColor = colorScheme.onTertiaryContainer;
        break;
      case LocationMode.hybrid:
        icon = Icons.desktop_windows;
        iconBg = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        break;
    }

    return Dismissible(
      key: Key(workshop.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Workshop'),
            content: const Text('Are you sure you want to delete this workshop?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<WorkshopProvider>().deleteWorkshop(workshop.id);
      },
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/workshop-detail', arguments: workshop),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workshop.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            workshop.locationMode.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(workshop.date)} • ${workshop.durationValue} ${workshop.durationUnit.label}',
                      style: TextStyle(color: colorScheme.secondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Workshop'),
                      content: const Text('Are you sure you want to delete this workshop?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    context.read<WorkshopProvider>().deleteWorkshop(workshop.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event_available, size: 48, color: colorScheme.outline),
            ),
            const SizedBox(height: 24),
            const Text(
              'Organize your sessions easily.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a workshop to view full participant analytics and materials.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
