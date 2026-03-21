import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../widgets/responsable_add_event_dialog.dart';

/// Événements créés par le responsable pour ses structures.
class ResponsableEventsPage extends StatefulWidget {
  const ResponsableEventsPage({super.key});

  @override
  State<ResponsableEventsPage> createState() => _ResponsableEventsPageState();
}

class _ResponsableEventsPageState extends State<ResponsableEventsPage> {
  bool _loading = true;
  List<EventResponse> _events = [];
  String _statusFilter = 'a_venir';

  /// Structures pour le dropdown "Créer un événement" (même source que Mes structures, mock pour l’instant).
  List<ResponsableStructureItem> _structuresForDialog = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final events = await client.cinePass.getMyEvents();
      final myStructure = await client.cinePass.getMyStructure();
      if (!mounted) return;
      setState(() {
        _events = events;
        _structuresForDialog = myStructure != null
            ? [
                ResponsableStructureItem(
                  id: myStructure.id.toString(),
                  name: myStructure.name,
                ),
              ]
            : [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _structuresForDialog = [];
        _loading = false;
      });
    }
  }

  void _openCreateEventDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => ResponsableAddEventDialog(
        structures: _structuresForDialog,
        onSaved: _load,
      ),
    );
  }

  Future<void> _deleteEvent(EventResponse event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Supprimer cet événement ?'),
        content: Text('Vous allez supprimer "${event.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await client.cinePass.deleteEvent(event.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Événement supprimé.' : 'Suppression impossible.'),
        backgroundColor: ok ? AppTheme.accentGreen : AppTheme.primaryRed,
      ),
    );
    if (ok) {
      await _load();
    }
  }

  Future<void> _showEditEventDialog(EventResponse event) async {
    final titleCtrl = TextEditingController(text: event.title);
    final categoryCtrl = TextEditingController(text: event.category);
    final cityCtrl = TextEditingController(text: event.city);
    final lieuCtrl = TextEditingController(text: event.location);
    final addressCtrl = TextEditingController(text: event.address ?? '');
    final dateCtrl = TextEditingController(text: event.date);
    final timeCtrl = TextEditingController(text: event.time);
    final placesCtrl = TextEditingController(text: event.placesTotal.toString());
    final priceCtrl = TextEditingController(text: event.price.toStringAsFixed(2));
    final descriptionCtrl = TextEditingController(text: event.description ?? '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Modifier l\'événement'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Titre')),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Catégorie')),
                TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Ville')),
                TextField(controller: lieuCtrl, decoration: const InputDecoration(labelText: 'Lieu')),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Adresse')),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (AAAA-MM-JJ)')),
                TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Heure (HH:mm)')),
                TextField(controller: placesCtrl, decoration: const InputDecoration(labelText: 'Places'), keyboardType: TextInputType.number),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Prix'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                TextField(controller: descriptionCtrl, decoration: const InputDecoration(labelText: 'Description')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              final parsedDate = DateTime.tryParse(dateCtrl.text.trim());
              if (parsedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Date invalide (AAAA-MM-JJ).')),
                );
                return;
              }
              final updated = await client.cinePass.updateEvent(
                id: event.id,
                titre: titleCtrl.text.trim(),
                categorie: categoryCtrl.text.trim(),
                description: descriptionCtrl.text.trim().isEmpty ? null : descriptionCtrl.text.trim(),
                lieu: lieuCtrl.text.trim(),
                adresse: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                ville: cityCtrl.text.trim(),
                eventDate: parsedDate,
                eventTimeStr: timeCtrl.text.trim(),
                placesTotal: int.tryParse(placesCtrl.text.trim()),
                prixBase: double.tryParse(priceCtrl.text.trim().replaceAll(',', '.')),
              );

              if (!mounted || !ctx.mounted) return;
              Navigator.of(ctx).pop();

              final ok = updated != null;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Événement mis à jour.' : 'Mise à jour impossible.'),
                  backgroundColor: ok ? AppTheme.accentGreen : AppTheme.primaryRed,
                ),
              );
              if (ok) {
                await _load();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  String _eventStatus(EventResponse event) {
    final d = DateTime.tryParse(event.date);
    if (d == null) return 'a_venir';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(d.year, d.month, d.day);
    if (eventDay.isBefore(today)) return 'archives';
    if (eventDay.isAfter(today)) return 'a_venir';
    return 'en_cours';
  }

  List<EventResponse> _filteredEvents() {
    if (_statusFilter == 'tous') return _events;
    return _events.where((e) => _eventStatus(e) == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleEvents = _filteredEvents();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes événements',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              FilledButton.icon(
                onPressed: _openCreateEventDialog,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Créer un événement'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Les événements que vous avez publiés pour vos structures.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('A venir'),
                selected: _statusFilter == 'a_venir',
                onSelected: (_) => setState(() => _statusFilter = 'a_venir'),
              ),
              ChoiceChip(
                label: const Text('En cours'),
                selected: _statusFilter == 'en_cours',
                onSelected: (_) => setState(() => _statusFilter = 'en_cours'),
              ),
              ChoiceChip(
                label: const Text('Archives'),
                selected: _statusFilter == 'archives',
                onSelected: (_) => setState(() => _statusFilter = 'archives'),
              ),
              ChoiceChip(
                label: const Text('Tous'),
                selected: _statusFilter == 'tous',
                onSelected: (_) => setState(() => _statusFilter = 'tous'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGreen),
            )
          else if (visibleEvents.isEmpty)
            Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 64,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun événement.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _openCreateEventDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Créer un événement'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleEvents.length,
              itemBuilder: (context, index) {
                final e = visibleEvents[index];
                final status = _eventStatus(e);
                return Card(
                  color: AppTheme.cardDark,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => context.go('/responsable/events/${e.id}'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event_rounded,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    title: Text(
                      e.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${e.category} • ${e.location}\n${e.date} ${e.time} • ${e.placesTotal} places • ${status == 'archives' ? 'Archive' : status == 'en_cours' ? 'En cours' : 'A venir'}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: () => _showEditEventDialog(e),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => _deleteEvent(e),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
