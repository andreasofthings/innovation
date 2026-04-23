import 'package:flutter/material.dart';
import '../models/method.dart';

class MethodSquareCard extends StatelessWidget {
  final Method method;
  final VoidCallback? onTap;

  const MethodSquareCard({
    super.key,
    required this.method,
    this.onTap,
  });

  String _formatRange(int? min, int? max, String unit) {
    if (min == null && max == null) return 'N/A';
    if (min != null && max != null) {
      if (min == max) return '$min $unit';
      return '$min-$max $unit';
    }
    return '${min ?? max} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final bool isWarmup = method.methodType.toLowerCase() == 'warmup';
    final Color accentColor = isWarmup ? const Color(0xFF25AFF4) : method.accentColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 6,
              color: accentColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            method.methodType.toUpperCase(),
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          method.icon,
                          size: 16,
                          color: accentColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        method.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatRange(method.minPeople, method.maxPeople, 'ppl'),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatRange(method.minTime, method.maxTime, 'min'),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
