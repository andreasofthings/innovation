import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workshop.dart';

class WorkshopDetailScreen extends StatelessWidget {
  final Workshop workshop;

  const WorkshopDetailScreen({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Details'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workshop.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoTile(
                    Icons.calendar_today,
                    'Date & Time',
                    DateFormat('MMM dd, yyyy • h:mm a').format(workshop.date),
                    colorScheme,
                  ),
                  _buildInfoTile(
                    Icons.location_on,
                    'Location',
                    workshop.type == WorkshopType.virtual ? 'Online' : 'Creative Hub, Room 402',
                    colorScheme,
                  ),
                  _buildInfoTile(
                    Icons.videocam,
                    'Virtual Access',
                    'Join Zoom Meeting',
                    colorScheme,
                    isLink: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Check-in Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Full Agenda', '4 Sessions Total', Icons.calendar_month),
                  _buildAgendaItem('09:00 - 10:30', 'Foundations of System Thinking', true),
                  _buildAgendaItem('10:45 - 12:30', 'Token Architecture & Handover', false, isLive: true),
                  _buildAgendaItem('13:30 - 15:00', 'Component Hardening', false),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Participants', '', Icons.people),
                  const SizedBox(height: 12),
                  const Text('15 confirmed guests', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Center(child: Text('Manage List')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&q=80&w=1000'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: [
                _buildOverlayTag(workshop.type.label, const Color(0xFF25AFF4)),
                const SizedBox(width: 8),
                _buildOverlayTag('IN-PROGRESS', const Color(0xFFF2994A)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, ColorScheme colorScheme, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isLink ? colorScheme.primary : null,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const Spacer(),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildAgendaItem(String time, String title, bool completed, {bool isLive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: completed ? Colors.blue : Colors.grey,
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    if (isLive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                        child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
