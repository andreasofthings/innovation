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
    return Card(
      elevation: 0,
      color: method.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // Based on ROUND_FOUR memory
        side: BorderSide(
          color: method.typeColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 8px horizontal color bar at the top
            Container(
              height: 8,
              width: double.infinity,
              color: method.typeColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          method.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            method.benefit,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            method.icon,
                            size: 18,
                            color: method.typeColor,
                          ),
                          const SizedBox(width: 4),
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final isFav = userProvider.isFavorite(method.id);
                              return GestureDetector(
                                onTap: () => userProvider.toggleFavorite(method.id),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: isFav ? Colors.red : method.typeColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
