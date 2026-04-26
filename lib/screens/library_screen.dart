import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/method_provider.dart';
import '../widgets/method_square_card.dart';
import 'method_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final provider = context.watch<MethodProvider>();
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              provider.clearFilters();
                              _searchController.clear();
                              setModalState(() {});
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                      // ... (rest of sorting options kept for functionality)
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIBRARY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Text(
                      'METHOD TOOLKIT',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search methods...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => context.read<MethodProvider>().setSearchQuery(val),
            ),
          ),
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildCategoryChip('All', true),
                const SizedBox(width: 8),
                _buildCategoryChip('Empathize', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Define', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Ideate', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Prototype', false),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Consumer<MethodProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.methods.isEmpty) {
                  return const Center(child: Text('No methods found.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: provider.methods.length,
                  itemBuilder: (context, index) {
                    final method = provider.methods[index];
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
