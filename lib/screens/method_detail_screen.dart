import 'package:flutter/material.dart';
import '../models/method.dart';

class MethodDetailScreen extends StatelessWidget {
  final Method method;

  const MethodDetailScreen({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(method.title),
        backgroundColor: method.accentColor.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(method.icon, color: method.accentColor, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.methodType.toUpperCase(),
                      style: TextStyle(
                        color: method.accentColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (method.parentTitle != null)
                      Text(
                        method.parentTitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(context, 'Benefit', method.benefit),
            _buildSection(context, 'Why', method.why),
            _buildSection(context, 'How', method.how),
            _buildSection(context, 'Input', method.methodInput),
            _buildSection(context, 'Output', method.methodOutput),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  context,
                  Icons.people_outline,
                  'People',
                  _formatRange(method.minPeople, method.maxPeople, 'ppl'),
                ),
                _buildInfoItem(
                  context,
                  Icons.access_time,
                  'Time',
                  _formatRange(method.minTime, method.maxTime, 'min'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (method.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: method.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: method.accentColor,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatRange(int? min, int? max, String unit) {
    if (min == null && max == null) return 'N/A';
    if (min != null && max != null) {
      if (min == max) return '$min $unit';
      return '$min-$max $unit';
    }
    return '${min ?? max} $unit';
  }
}
