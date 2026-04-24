import 'package:flutter/material.dart';
import '../models/method.dart';

class MethodDetailScreen extends StatelessWidget {
  final Method method;

  const MethodDetailScreen({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Method Details', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInputOutputSection(context),
                  const SizedBox(height: 16),
                  if (method.benefit.isNotEmpty)
                    _buildCollapsibleSection(
                      context,
                      title: 'THE "WHY" / BENEFIT',
                      content: method.benefit,
                      icon: Icons.stars,
                      color: const Color(0xFFE1F5FE),
                      iconColor: const Color(0xFF0277BD),
                    ),
                  if (method.why.isNotEmpty && method.why != method.benefit) ...[
                    const SizedBox(height: 16),
                    _buildCollapsibleSection(
                      context,
                      title: 'ADDITIONAL CONTEXT (WHY)',
                      content: method.why,
                      icon: Icons.help_outline,
                      color: const Color(0xFFFFF9C4),
                      iconColor: const Color(0xFFF57F17),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildProcessSection(context),
                  if (method.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tags',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: method.tags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.grey.shade200),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: method.typeColor.withOpacity(0.8),
      ),
      child: Stack(
        children: [
          // Placeholder pattern or image
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Icon(method.icon, size: 200, color: Colors.white),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: method.typeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        method.methodType.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatRange(method.minTime, method.maxTime, 'MINUTES'),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  method.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputOutputSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            title: 'METHOD INPUT',
            content: method.methodInput,
            icon: Icons.layers_outlined,
            iconColor: const Color(0xFF006590),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            context,
            title: 'METHOD OUTPUT',
            content: method.methodOutput,
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF845400),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required String content, required IconData icon, required Color iconColor}) {
    // Basic splitting, improved to avoid empty strings
    final items = content
        .split(RegExp(r'[,.\n]'))
        .map((s) => s.trim())
        .where((s) => s.length > 1) // Avoid single chars/punctuation
        .toList();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty && content.isNotEmpty)
              Text(content, style: const TextStyle(fontSize: 11, color: Colors.black87))
            else
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection(BuildContext context,
      {required String title,
      required String content,
      required IconData icon,
      required Color color,
      required Color iconColor}) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: iconColor.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessSection(BuildContext context) {
    if (method.how.isEmpty) return const SizedBox.shrink();

    final steps = _parseSteps(method.how);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_list_bulleted, size: 20, color: Color(0xFF3C627D)),
            const SizedBox(width: 8),
            Text(
              'The "How" / Process',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B0FF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  List<String> _parseSteps(String how) {
    // Attempt to split by numbered lines
    final lines = how.split(RegExp(r'\n+'));
    final steps = <String>[];
    for (var line in lines) {
      final trimmed = line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim();
      if (trimmed.isNotEmpty) {
        steps.add(trimmed);
      }
    }
    // If we only got one step, maybe it's a paragraph we should split by sentences?
    if (steps.length == 1 && steps[0].contains('. ')) {
        final sentenceSplit = steps[0].split(RegExp(r'(?<=\.)\s+'));
        if (sentenceSplit.length > 1) return sentenceSplit;
    }

    return steps.isEmpty ? [how] : steps;
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
