import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/method_provider.dart';
import '../widgets/method_square_card.dart';

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
    final provider = context.read<MethodProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters & Sorting',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
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
                      ListTile(
                        title: const Text('Alphabetical (A-Z)'),
                        leading: Radio<MethodSort>(
                          value: MethodSort.alphabeticalAsc,
                          groupValue: provider.currentSort,
                          onChanged: (val) {
                            provider.setSort(val!);
                            setModalState(() {});
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Alphabetical (Z-A)'),
                        leading: Radio<MethodSort>(
                          value: MethodSort.alphabeticalDesc,
                          groupValue: provider.currentSort,
                          onChanged: (val) {
                            provider.setSort(val!);
                            setModalState(() {});
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Latest First'),
                        leading: Radio<MethodSort>(
                          value: MethodSort.dateLatest,
                          groupValue: provider.currentSort,
                          onChanged: (val) {
                            provider.setSort(val!);
                            setModalState(() {});
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Oldest First'),
                        leading: Radio<MethodSort>(
                          value: MethodSort.dateOldest,
                          groupValue: provider.currentSort,
                          onChanged: (val) {
                            provider.setSort(val!);
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Parent Page', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: provider.selectedParentTitle,
                        hint: const Text('Select Parent Page'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Parents'),
                          ),
                          ...provider.availableParentTitles.map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p),
                          )),
                        ],
                        onChanged: (val) {
                          provider.setParentFilter(val);
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: provider.availableTags.map((tag) {
                          final isSelected = provider.selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (_) {
                              provider.toggleTag(tag);
                              setModalState(() {});
                            },
                          );
                        }).toList(),
                      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search methods...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<MethodProvider>().setSearchQuery('');
                  },
                ),
              ),
              onChanged: (val) => context.read<MethodProvider>().setSearchQuery(val),
            ),
          ),
          Expanded(
            child: Consumer<MethodProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load methods.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.fetchMethods,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.methods.isEmpty) {
                  return const Center(child: Text('No methods found.'));
                }

                final width = MediaQuery.of(context).size.width;
                final crossAxisCount = width > 600 ? 4 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: provider.methods.length,
                  itemBuilder: (context, index) {
                    final method = provider.methods[index];
                    return MethodSquareCard(
                      method: method,
                      onTap: () {
                        // TODO: Navigate to Method Detail Screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected: ${method.title}')),
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
}
