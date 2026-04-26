import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/method.dart';
import '../providers/user_provider.dart';

class MethodSquareCard extends StatelessWidget {
  final Method method;
  final VoidCallback? onTap;

  const MethodSquareCard({
    super.key,
    required this.method,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(0), // Stitch shows square corners for cards
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Top Accent Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(color: method.typeColor),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: method.typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(method.icon, size: 20, color: method.typeColor),
                      ),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final isFav = userProvider.isFavorite(method.id);
                          return GestureDetector(
                            onTap: () => userProvider.toggleFavorite(method.id),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isFav ? Colors.red : colorScheme.outlineVariant,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    method.title.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 10, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '30m', // Default placeholder if not in model
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurfaceVariant,
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
}
