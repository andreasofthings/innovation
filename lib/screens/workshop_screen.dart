import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workshop_provider.dart';
import '../models/workshop.dart';

class WorkshopScreen extends StatelessWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: colorScheme.onSurface),
                const SizedBox(width: 12),
                const Text(
                  'Workshop Planner',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterButton(context, 'All Status'),
                const SizedBox(width: 8),
                _buildFilterButton(context, 'Date: Newest'),
                const SizedBox(width: 8),
                _buildFilterButton(context, 'Session Type'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // List
          Expanded(
            child: Consumer<WorkshopProvider>(
              builder: (context, provider, child) {
                final workshops = provider.workshops;
                if (workshops.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  itemCount: workshops.length,
                  itemBuilder: (context, index) {
                    final workshop = workshops[index];
                    return _buildWorkshopItem(context, workshop);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }

  Widget _buildWorkshopItem(BuildContext context, Workshop workshop) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPlanned = workshop.status == WorkshopStatus.planned;

    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (workshop.type) {
      case WorkshopType.virtual:
        icon = Icons.videocam;
        iconBg = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        break;
      case WorkshopType.onSite:
        icon = Icons.person;
        iconBg = colorScheme.tertiaryContainer;
        iconColor = colorScheme.onTertiaryContainer;
        break;
      case WorkshopType.hybrid:
        icon = Icons.desktop_windows;
        iconBg = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        break;
    }

    return InkWell(
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
                      Text(
                        workshop.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          workshop.type.label,
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
                    '${DateFormat('MMM dd, yyyy').format(workshop.date)} • ${DateFormat('h:mm a').format(workshop.date)}',
                    style: TextStyle(color: colorScheme.secondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              workshop.status.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isPlanned ? colorScheme.primary : colorScheme.outline,
                letterSpacing: 1.2,
              ),
            ),
          ],
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
