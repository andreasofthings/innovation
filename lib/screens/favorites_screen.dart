import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/method_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/method_square_card.dart';
import 'method_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer2<MethodProvider, UserProvider>(
        builder: (context, methodProvider, userProvider, child) {
          if (methodProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteIds = userProvider.profile?.favorites ?? [];
          final favoriteMethods = methodProvider.methods
              .where((m) => favoriteIds.contains(m.id))
              .toList();

          if (favoriteMethods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Discover methods in the library and like them!'),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: favoriteMethods.length,
                itemBuilder: (context, index) {
                  final method = favoriteMethods[index];
                  return MethodSquareCard(
                    method: method,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MethodDetailScreen(method: method),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
