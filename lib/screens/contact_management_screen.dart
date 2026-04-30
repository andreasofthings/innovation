import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../models/workshop.dart';
import '../models/participant.dart';
import '../providers/contact_provider.dart';
import '../providers/workshop_provider.dart';
import '../providers/participant_provider.dart';

class ContactManagementScreen extends StatefulWidget {
  const ContactManagementScreen({super.key});

  @override
  State<ContactManagementScreen> createState() => _ContactManagementScreenState();
}

class _ContactManagementScreenState extends State<ContactManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().fetchContacts();
      context.read<WorkshopProvider>().fetchWorkshops();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Google Contacts',
            onPressed: () => _handleSync(context),
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
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: Consumer<ContactProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.contacts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredContacts = provider.contacts.where((c) {
                  final query = _searchController.text.toLowerCase();
                  return c.firstName.toLowerCase().contains(query) ||
                      c.lastName.toLowerCase().contains(query) ||
                      c.email.toLowerCase().contains(query);
                }).toList();

                if (filteredContacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No contacts found'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filteredContacts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: contact.photoUrl != null && contact.photoUrl!.isNotEmpty
                            ? NetworkImage(contact.photoUrl!)
                            : null,
                        child: contact.photoUrl == null || contact.photoUrl!.isEmpty
                            ? Text(contact.firstName.isNotEmpty ? contact.firstName[0] : '?')
                            : null,
                      ),
                      title: Text(contact.fullName),
                      subtitle: Text(contact.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showWorkshopSelectionDialog(context, contact),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleSync(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final success = await context.read<ContactProvider>().syncGoogleContacts();
    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Contacts synced successfully')),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Failed to sync contacts')),
      );
    }
  }

  void _showAddContactDialog(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isEmpty) return;
              final newContact = Contact(
                id: '',
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
              );
              final success = await context.read<ContactProvider>().addContact(newContact);
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showWorkshopSelectionDialog(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (context) {
        final workshops = context.watch<WorkshopProvider>().workshops;
        final plannedWorkshops = workshops.where((w) => w.date.isAfter(DateTime.now())).toList();

        return AlertDialog(
          title: Text('Add ${contact.fullName} to Workshop'),
          content: plannedWorkshops.isEmpty
              ? const Text('No planned workshops found.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: plannedWorkshops.length,
                    itemBuilder: (context, index) {
                      final workshop = plannedWorkshops[index];
                      return ListTile(
                        title: Text(workshop.title),
                        subtitle: Text(DateFormat('MMM dd, yyyy').format(workshop.date)),
                        onTap: () => _addParticipant(context, workshop, contact),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addParticipant(BuildContext context, Workshop workshop, Contact contact) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final participant = WorkshopParticipant(
      id: '',
      workshop: workshop.id,
      firstName: contact.firstName,
      lastName: contact.lastName,
      email: contact.email,
      source: contact.source,
      googleContactId: contact.googleContactId,
    );

    final success = await context.read<ParticipantProvider>().addParticipant(participant);
    if (context.mounted) {
      Navigator.pop(context);
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('${contact.fullName} added to ${workshop.title}')),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to add participant')),
        );
      }
    }
  }
}
