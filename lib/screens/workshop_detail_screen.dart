import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workshop.dart';
import '../models/participant.dart';
import '../models/session.dart';
import '../providers/participant_provider.dart';
import '../providers/session_provider.dart';

class WorkshopDetailScreen extends StatefulWidget {
  final Workshop workshop;

  const WorkshopDetailScreen({super.key, required this.workshop});

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParticipantProvider>().fetchParticipants(widget.workshop.id);
      context.read<SessionProvider>().fetchSessions(widget.workshop.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Workshop Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.workshop.locationMode == LocationMode.virtual ? Icons.videocam : Icons.person,
                      size: 32,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.workshop.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('EEEE, MMMM dd').format(widget.workshop.date)} @ ${DateFormat('h:mm a').format(widget.workshop.date)}',
                    style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeaderTag(context, widget.workshop.locationMode.label, colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                      const SizedBox(width: 8),
                      _buildHeaderTag(context, widget.workshop.status.label, colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PARTICIPANTS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () => _showAddParticipantDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<ParticipantProvider>(
              builder: (context, provider, child) {
                final participants = provider.getParticipants(widget.workshop.id);
                if (provider.isLoading && participants.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (participants.isEmpty) {
                  return const Text('No participants added yet.', style: TextStyle(fontStyle: FontStyle.italic));
                }
                return Column(
                  children: participants.map((p) => _buildParticipantItem(context, p)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SESSIONS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () => _showAddSessionDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<SessionProvider>(
              builder: (context, provider, child) {
                final sessions = provider.getSessions(widget.workshop.id);
                if (provider.isLoading && sessions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (sessions.isEmpty) {
                  return const Text('No sessions planned yet.', style: TextStyle(fontStyle: FontStyle.italic));
                }
                return Column(
                  children: sessions.map((s) => _buildSessionItem(context, s)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTag(BuildContext context, String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildParticipantItem(BuildContext context, WorkshopParticipant participant) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.surfaceContainerHigh,
            child: Text(participant.firstName[0], style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(participant.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(participant.email, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => context.read<ParticipantProvider>().deleteParticipant(widget.workshop.id, participant.id),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(BuildContext context, WorkshopSession session) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.event_note, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${session.durationMinutes} min', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => context.read<SessionProvider>().deleteSession(widget.workshop.id, session.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddParticipantDialog(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Participant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final p = WorkshopParticipant(
                id: '',
                workshop: widget.workshop.id,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
              );
              context.read<ParticipantProvider>().addParticipant(p);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSessionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duration (min)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final s = WorkshopSession(
                id: '',
                workshop: widget.workshop.id,
                title: titleController.text,
                durationMinutes: int.tryParse(durationController.text) ?? 60,
              );
              context.read<SessionProvider>().addSession(s);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
