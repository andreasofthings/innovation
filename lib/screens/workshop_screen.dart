import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workshop_provider.dart';
import '../models/workshop.dart';

class WorkshopScreen extends StatelessWidget {
  const WorkshopScreen({super.key});

  void _showFilterDialog(BuildContext context) {
    final provider = context.read<WorkshopProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Filter & Sort'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<WorkshopStatus?>(
                      value: provider.statusFilter,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Status')),
                        ...WorkshopStatus.values.map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                            )),
                      ],
                      onChanged: (val) {
                        provider.setStatusFilter(val);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<WorkshopType?>(
                      value: provider.typeFilter,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Types')),
                        ...WorkshopType.values.map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                            )),
                      ],
                      onChanged: (val) {
                        provider.setTypeFilter(val);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Sort By Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    ListTile(
                      title: const Text('Newest First'),
                      leading: Radio<WorkshopSort>(
                        value: WorkshopSort.dateNewest,
                        groupValue: provider.currentSort,
                        onChanged: (val) {
                          provider.setSort(val!);
                          setModalState(() {});
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Oldest First'),
                      leading: Radio<WorkshopSort>(
                        value: WorkshopSort.dateOldest,
                        groupValue: provider.currentSort,
                        onChanged: (val) {
                          provider.setSort(val!);
                          setModalState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    WorkshopType selectedType = WorkshopType.virtual;
    WorkshopStatus selectedStatus = WorkshopStatus.planned;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    DropdownButtonFormField<WorkshopType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: WorkshopType.values.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                      )).toList(),
                      onChanged: (val) => setModalState(() => selectedType = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<WorkshopStatus>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: WorkshopStatus.values.map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                      )).toList(),
                      onChanged: (val) => setModalState(() => selectedStatus = val!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (time != null) {
                            setModalState(() {
                              selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
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
                    if (titleController.text.isNotEmpty) {
                      context.read<WorkshopProvider>().addWorkshop(Workshop(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text,
                            type: selectedType,
                            status: selectedStatus,
                            date: selectedDate,
                          ));
                      Navigator.pop(context);
                    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF6FAFF),
      appBar: AppBar(
        title: const Text('Workshop Planner'),
        leading: const Icon(Icons.calendar_today),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_agenda_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child: Consumer<WorkshopProvider>(
              builder: (context, provider, child) {
                if (provider.workshops.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.workshops.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return WorkshopListItem(workshop: provider.workshops[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFF25AFF4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final provider = context.watch<WorkshopProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          _FilterChip(
            label: provider.statusFilter?.label ?? 'All Status',
            onTap: () => _showFilterDialog(context),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Date: ${provider.currentSort == WorkshopSort.dateNewest ? 'Newest' : 'Oldest'}',
            onTap: () => _showFilterDialog(context),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: provider.typeFilter?.label ?? 'Session',
            onTap: () => _showFilterDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Organize your sessions easily.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Select a workshop to view full participant analytics and materials.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }
}

class WorkshopListItem extends StatelessWidget {
  final Workshop workshop;

  const WorkshopListItem({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/workshop-detail', arguments: workshop);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _buildLeadingIcon(),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _buildTypeTag(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${DateFormat('MMM dd, yyyy • h:mm a').format(workshop.date)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        workshop.status.label,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData icon;
    Color bgColor;

    switch (workshop.type) {
      case WorkshopType.virtual:
        icon = Icons.videocam;
        bgColor = const Color(0xFF25AFF4);
        break;
      case WorkshopType.onSite:
        icon = Icons.person_add_alt_1; // Close to the design icon
        bgColor = const Color(0xFFF2994A);
        break;
      case WorkshopType.hybrid:
        icon = Icons.computer;
        bgColor = const Color(0xFF25AFF4);
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildTypeTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFBDE3FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        workshop.type.label,
        style: const TextStyle(
          color: Color(0xFF006590),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
